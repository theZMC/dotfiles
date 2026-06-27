---
name: create-github-issue
description: Creates a well-structured GitHub issue with Motivation, Acceptance Criteria, and optional References sections using the GitHub CLI (`gh`). Use when the user asks to create, file, or open a GitHub issue.
metadata:
  author: Zach Callahan
  version: "1.5"
---

# Create GitHub Issue (gh CLI)

## When to use this skill

Use this skill when the user asks to create, file, or open a GitHub issue.

## Required information

Before creating the issue, gather the following from the user or infer from
context:

1. **Repository**: The `owner` and `repo` name. If working inside a git
   repository, infer from the remote origin.
2. **Motivation**: Why this issue matters and what problem it addresses.
3. **Acceptance Criteria**: Specific conditions that must be met for the issue
   to be considered resolved.
4. **References** (optional): Relevant links, documents, or resources.
5. **Project target** (optional): A GitHub Project name/number when the user
   asks to add issues to a project.
6. **Dependencies** (for multiple issues): If creating multiple issues with
   clear sequencing, identify which issues are blocked by others and always
   create the dependency graph.

If the user has not provided enough detail for the Motivation or Acceptance
Criteria sections, ask before proceeding.

## Issue body format

Structure the issue body exactly as follows:

```markdown
## Motivation

<A brief explanation of why this issue is important and what problem it addresses.>

## Acceptance Criteria

- [ ] Description of the first acceptance criterion.
- [ ] Description of the second acceptance criterion.
  - [ ] Description of a sub-criterion of the second criterion.

## References

- [Link text](url)
- Any other relevant resources
```

- The **Motivation** section is mandatory.
- The **Acceptance Criteria** section is mandatory. Each criterion must be a
  markdown checkbox (`- [ ]`). Use nested checkboxes for sub-criteria.
- The **References** section is optional. Omit it entirely (including the
  heading) if there are no references.
- Any repository file/doc references **must** use full GitHub URLs pinned to a
  ref (for example,
  `https://github.com/<owner>/<repo>/blob/<branch-or-sha>/path/to/file.ts`). Do
  not use relative paths like `../docs/...` or `plugins/...`.

## Title generation

Generate the issue title from the Motivation content. The title should be:

- Concise (under 80 characters when possible)
- Descriptive enough to convey the issue at a glance
- Written in imperative mood (e.g., "Add pagination to user list endpoint")

## Steps

1. Determine the target repository (`owner`/`repo`).

   - If you are inside the target repository, run:

     ```bash
     gh repo view
     ```

     to confirm authentication and repository context.

   - If you are not in the target repository (or context may be ambiguous), use
     explicit `--repo <owner>/<repo>` on all `gh` commands.

2. Draft the Motivation, Acceptance Criteria, and References (if any) based on
   user input.
3. Generate a concise, descriptive title from the Motivation.
4. Present the draft title and body to the user for confirmation before
   creating.
5. Create the issue with the `github:issue:create` mise task. It wraps
   `gh issue create` with transient-failure retries and prints `{number,url,id}`
   JSON to stdout (so you get the node id without a separate lookup):

   ```bash
   mise run github:issue:create --repo <owner>/<repo> --title "<title>" --body-file <path>
   ```

   **Always pass the body via `--body-file`, never `--body`.** Write the markdown
   body to a file first (e.g. a `mktemp` path). This sidesteps all shell
   heredoc/backtick escaping problems — issue bodies routinely contain inline
   code spans and fenced code blocks, and `--body-file` passes them through
   verbatim with no shell interpretation. If labels or assignees are requested,
   add `--label <comma,separated>` and/or `--assignee <comma,separated>`.

   To create the issue and place it on a project in one step, add
   `--project <name-or-number>` (fuzzy title or number) and optionally
   `--status <option>`:

   ```bash
   mise run github:issue:create --repo <owner>/<repo> --title "<title>" \
     --body-file <path> --project "<project>" --status Ready
   ```

6. If multiple related issues were created, automatically apply dependency links
   before finishing (see
   [Creating multiple related issues](#creating-multiple-related-issues)).
7. If a project target is specified, ensure each issue is on the project with the
   correct status (see [Project assignment](#project-assignment)).
8. Report the created issue number and URL back to the user.

## Creating multiple related issues

When creating multiple issues in one request:

1. Create all issues first. `github:issue:create` returns `{number,url,id}` JSON
   per issue, so capture each number/URL straight from its output — no separate
   node-id lookup is required.

2. Build a dependency graph for clearly dependent issues. If issue B cannot be
   completed without issue A, link **B blocked by A**:

   ```bash
   mise run github:issue:blocked-by:add --repo <owner>/<repo> --issue <B> --by <A>
   ```

3. Verify an issue's dependency links when practical (returns a JSON array of
   blockers, `[]` when none):

   ```bash
   mise run github:issue:blocked-by:list --repo <owner>/<repo> --issue <number>
   ```

4. Do this dependency-linking step automatically when dependencies are known; do
   not leave dependency graph creation as an optional manual follow-up.

## Project assignment

If the user specifies a project in the initial "create these issues" request,
place every created issue on that project before finishing. The
`github:project:status:set` mise task resolves the project (by fuzzy name or
number), finds the `Status` field and the requested option, adds the issue to
the project if it isn't already an item, and sets the status — all in one call,
with transient-failure retries:

```bash
mise run github:project:status:set --owner <owner> --repo <repo> \
  --issue <number> --project "<name-or-number>" --status Ready --skip-if-blocked
```

- `--project` accepts a fuzzy title (e.g. `"centralized cluster management"`
  resolves to `Centralized Cluster Management`) or a project number. If a name is
  ambiguous the task prints the candidates and exits non-zero; re-run with an
  exact name or the number.
- `--skip-if-blocked` encodes the Ready-vs-Backlog rule: issues with open
  blockers are left unchanged (in `Backlog`); non-blocked issues move to `Ready`.
  Apply the dependency links (above) **first** so this rule sees them.
- The task needs the `project` and `read:project` scopes. If a scope error
  appears, refresh once and retry:

  ```bash
  gh auth refresh -s read:project -s project
  ```

`github:issue:create --project <...> --status <...>` performs the same placement
inline at creation time. Use the standalone `github:project:status:set` task
when status must be set *after* dependency links exist (so `--skip-if-blocked`
can take effect).

## Labels and assignees

If the user specifies labels or assignees, include them in the `gh issue create`
command with `--label` and `--assignee`. Do not add labels or assignees unless
requested.
