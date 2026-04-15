---
name: work-github-issue
description: |
  Works a GitHub issue end-to-end using gh CLI: reads issue, creates branch,
  implements changes, keeps one signed conventional commit (amended as needed),
  opens PR, requests @copilot review, triages feedback, and performs final
  ff-only merge after user approval.
metadata:
  author: Zach Callahan
  version: "1.3"
---

# Work GitHub Issue (gh CLI)

## Use when

Use when the user wants an issue worked end-to-end: branch, implementation,
single signed commit, PR, `@copilot` triage, and final ff-only merge.

## Required input

1. Issue id (number or URL).
2. Repository (`owner/repo`, infer from git remote when possible).
3. Base branch (optional; default to repo default branch).

If issue id cannot be inferred, ask for it.

## Preconditions

- `gh` authenticated and repo-accessible.
- `gh` version `2.88.0+` (Copilot reviewer support).
- GPG signing configured for git.
- Working tree clean before branch creation.

If working tree is dirty, stop and ask user how to proceed.

## Guardrails

- Ask user only when truly blocked.
- Keep exactly one commit for the issue across the full lifecycle; maintain via
  amend.
- Use `--force-with-lease` after amend (never `--force`).
- Do not paste issue body content into commit/PR text.
- Do not merge before user approval.
- Do not merge unless all non-skipped checks pass.

## Branch naming

Use `<issue-number>-<slugified-issue-title>`.

Slug rules: lowercase ASCII; replace non-alphanumeric runs with `-`; collapse
repeated `-`; trim edges; keep practical length (for example 60 chars).

If branch exists, append a short numeric or timestamp suffix.

## Commit + PR message rules

- Commit must be signed: `git commit -S`.
- Commit subject must be a valid conventional commit.
- Commit body is required and must be:

```markdown
Closes #<issue-number>

## Summary

- <change 1>
- <change 2>
- <change 3>
```

- Keep summary concise and implementation-focused.
- PR title must match commit subject.
- Create PR with commit fill so PR body comes from commit body:
  `gh pr create --fill-verbose`.

## Workflow

1. Resolve repo context: `gh repo view`.
2. Read issue:
   `gh issue view <issue-number> --repo <owner>/<repo> --json number,title,body,url,state,labels,assignees`.
   If closed/inaccessible, stop and report why.
3. Determine base branch: `gh repo view <owner>/<repo> --json defaultBranchRef`.
4. Sync base (`git fetch`, `git checkout <base>`, `git pull --ff-only`) and
   create issue branch.
5. Implement from issue requirements; run relevant tests/validation.
6. Create one signed commit using required message format; verify one commit on
   top of base.
7. Push branch: `git push -u origin <branch>`.
8. Open PR with fill:
   `gh pr create --repo <owner>/<repo> --base <base> --head <branch> --fill-verbose`.
9. Request/wait for Copilot via mise:
   `mise run github:pr:copilot:request-and-wait --owner <owner> --repo <repo> --pr <pr-number>`.
   If unavailable, report and ask whether to continue without Copilot.
10. Triage review comments (`gh pr view ... --json ...` +
    `gh api repos/.../pulls/.../comments`):
    - must-fix: correctness/test/security/defects
    - optional: style/preference
    - needs-decision: behavior tradeoffs requiring user input For accepted
      changes: modify code, re-run checks, amend + force-with-lease.
    - **I am explicitly requesting you amend commits**
    - If commit message unchanged: `git commit --amend -S --no-edit`
    - If summary/body changed: `git commit --amend -S` and keep required body
      format.
11. Validate checks gate:
    - Quiet wait + final snapshot via mise task:
      `mise run github:pr:checks:wait-and-report --owner <owner> --repo <repo> --pr <pr-number>`
      Proceed only when checks are pass/skipping. On fail/cancel, return to
      triage.
12. After user approval, ff-only merge:
    `git fetch origin && git checkout <base> && git merge --ff-only <branch> && git push origin <base>`.
    If ff-only merge blocked, stop and report blocker.

## Progress updates to user

Report at these checkpoints:

1. Issue loaded (number/title/url).
2. Branch created/checked out.
3. Validation result and commit SHA.
4. PR URL and Copilot status.
5. Triage outcomes and decisions needed.
6. Check status for all non-skipped checks.
7. Merge result or exact blocker.

## Failure handling

- On command failure: report command, key error, next action.
- If Copilot feedback times out (15-minute bounded wait), ask whether to
  continue with human review.
- If checks remain pending after bounded wait, ask whether to continue waiting
  and list pending checks.
- If checks fail/cancel, do not merge; report failing checks and return to
  fix-and-amend loop.
- If policy/protection blocks merge, do not bypass; report exact blocker.
