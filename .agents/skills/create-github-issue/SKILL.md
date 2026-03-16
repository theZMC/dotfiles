---
name: create-github-issue
description: Creates a well-structured GitHub issue with Motivation, Acceptance Criteria, and optional References sections using the GitHub CLI (`gh`). Use when the user asks to create, file, or open a GitHub issue.
metadata:
  author: Zach Callahan
  version: "1.2"
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

- [ ] Criterion 1: Description of the first acceptance criterion.
- [ ] Criterion 2: Description of the second acceptance criterion.
  - [ ] Criterion 2a: Description of a sub-criterion.

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
5. Use the GitHub CLI to create the issue:

   ```bash
   gh issue create --repo <owner>/<repo> --title "<title>" --body "<body>"
   ```

   For multiline bodies, prefer a heredoc-safe form:

   ```bash
   gh issue create --repo <owner>/<repo> --title "<title>" --body "$(cat <<'EOF'
   <issue body markdown>
   EOF
   )"
   ```

   If labels or assignees are requested, include them with `--label` and
   `--assignee`.

6. If multiple related issues were created, automatically apply dependency
   links before finishing.
7. If a project target is specified, add each issue to the project and move
   non-blocked issues to `Ready`.
8. Report the created issue number and URL back to the user.

## Creating multiple related issues

When creating multiple issues in one request:

1. Create all issues first and capture each issue number + node ID.

   - You can fetch node IDs with:

     ```bash
     gh issue view <number> --repo <owner>/<repo> --json id,number,title,url
     ```

2. Build a dependency graph for clearly dependent issues.

   - If issue B cannot be completed without issue A, set **B blocked by A**.
   - Use GraphQL `addBlockedBy` mutation:

     ```bash
     gh api graphql -f query='mutation($issueId:ID!, $blockingIssueId:ID!){ addBlockedBy(input:{issueId:$issueId, blockingIssueId:$blockingIssueId}) { clientMutationId } }' -f issueId='<blocked-issue-node-id>' -f blockingIssueId='<blocking-issue-node-id>'
     ```

3. Verify dependency links for each issue when practical:

   ```bash
   gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner,name:$repo){ issue(number:$number){ number blockedBy(first:20){ nodes { number title url } } } } }' -f owner='<owner>' -f repo='<repo>' -F number=<issue-number>
   ```

4. Do this dependency-linking step automatically when dependencies are known;
   do not leave dependency graph creation as an optional manual follow-up.

## Project assignment

If the user specifies a project in the initial "create these issues" request,
add every created issue to that project before finishing.

1. Add issue to project by name:

   ```bash
   gh issue edit <number> --repo <owner>/<repo> --add-project "<Project Name>"
   ```

2. If project lookup fails, verify project access and available projects:

   ```bash
   gh project list --owner <owner> --format json
   ```

3. If project scopes are missing, ask the user to refresh auth scopes and then
   continue:

   ```bash
   gh auth refresh -s read:project -s project
   ```

4. After adding issues to the project, move all non-blocked issues to `Ready`.
   Keep blocked issues in `Backlog`.

   - Get the project id, `Status` field id, and option ids:

     ```bash
     gh api graphql -f query='query($owner:String!, $number:Int!) { organization(login:$owner) { projectV2(number:$number) { id title fields(first:50) { nodes { ... on ProjectV2FieldCommon { id name } ... on ProjectV2SingleSelectField { id name options { id name } } } } } } }' -f owner='<owner>' -F number=<project-number>
     ```

   - Get each issue's project item id and whether it is blocked:

     ```bash
     gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner,name:$repo){ issue(number:$number){ number blockedBy(first:20){ nodes { number } } projectItems(first:20){ nodes { id project { ... on ProjectV2 { id title number } } } } } } }' -f owner='<owner>' -f repo='<repo>' -F number=<issue-number>
     ```

   - Move non-blocked issues to `Ready`:

     ```bash
     gh project item-edit --project-id <project-id> --id <project-item-id> --field-id <status-field-id> --single-select-option-id <ready-option-id>
     ```

   - Rule: if `blockedBy.nodes` is empty, set status to `Ready`; otherwise
     leave status unchanged (typically `Backlog`).

## Labels and assignees

If the user specifies labels or assignees, include them in the
`gh issue create` command with `--label` and `--assignee`. Do not add labels or
assignees unless requested.
