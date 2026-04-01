---
name: work-github-issue
description: |
  Works a GitHub issue end-to-end using gh CLI: reads issue, creates branch,
  implements changes, creates one signed conventional commit, opens PR with
  close semantics, requests @copilot review, triages feedback by amending,
  and performs final ff-only merge after user approval.
metadata:
  author: Zach Callahan
  version: "1.2"
---

# Work GitHub Issue (gh CLI)

## When to use this skill

Use when the user wants an issue worked end-to-end: branch, implementation,
single signed commit, PR, `@copilot` triage, and final ff-only merge.

## Required information

Gather:

1. **Issue identifier**: number or full URL.
2. **Repository**: `owner/repo` (infer from git remote if possible).
3. **Target base branch** (optional): default to repo default branch.

If issue id cannot be inferred, ask for it.

## Preconditions

- `gh` is authenticated with repo access.
- `gh` CLI is `2.88.0+` (`@copilot` reviewer support).
- GPG signing is configured in git.
- Working tree is clean before branch creation.

If the working tree is dirty, stop and ask the user how to proceed.

## Guardrails

- Ask the user only when truly blocked.
- Do not paste the issue body into commit messages or PR body.
- Keep exactly one commit for the issue across the full lifecycle (initial
  implementation and all post-review fixes); maintain via amend.
- Use `--force-with-lease` (never `--force`) after amend.
- Do not merge until the user gives final approval.
- Do not merge until all non-skipped PR checks are complete and passing.

## Branch naming

Use:

```text
<issue-number>-<slugified-issue-title>
```

Slug rules: lowercase ASCII, replace non-alphanumeric runs with `-`, collapse
repeated `-`, trim edges, keep practical length (for example 60 chars).

If the branch already exists, append a short numeric or timestamp suffix.

## Conventional commit rules

- Exactly one signed commit: `git commit -S`.
- Subject is valid conventional commit (for example
  `feat(auth): add session refresh endpoint`).
- Subject line only: no body, no footer, no issue content.

## PR body format

Use exactly:

```markdown
Closes #<issue-number>

## Summary

- <change 1>
- <change 2>
- <change 3>
```

- PR title exactly matches commit subject.
- Keep summary concise and implementation-focused.

## Steps

1. Resolve repo and issue context.

   - `gh repo view`
   - Use `<owner>/<repo>` consistently when needed.

2. Read issue details.

   - `gh issue view <issue-number> --repo <owner>/<repo> --json number,title,body,url,state,labels,assignees`
   - If issue is closed or inaccessible, stop and report the reason.

3. Determine base branch and ensure local sync.
   - `gh repo view <owner>/<repo> --json defaultBranchRef`
   - Fetch remotes and ensure local base is up to date before branching.

4. Create and check out the issue branch.
   - Branch from latest base tip with generated name.

5. Implement the issue.
   - Work directly from issue requirements.
   - Ask only for ambiguities that materially change behavior.
   - Run relevant tests/validation before commit.

6. Create a single signed conventional commit.
   - Stage intended files and commit:
     `git commit -S -m "<conventional-commit-subject>"`
   - Verify only one commit exists on top of base.

7. Push branch.
   - `git push -u origin <branch-name>`

8. Open PR targeting default branch.
   - Create PR with title exactly equal to commit subject.
   - Use required body format (`Closes #<issue-number>` + `## Summary` bullets).
   - Prefer heredoc-safe body creation.

9. Request Copilot review and wait via mise task.
   - Run exactly:
     `mise run github:pr:copilot:request-and-wait --owner <owner> --repo <repo> --pr <pr-number>`
   - If this task fails because Copilot review is unavailable, report clearly
     and ask user whether to continue without Copilot.

10. Review triage loop.

    - Task semantics:
      - Returns success when Copilot summary says `generated no comments`.
      - Returns success when Copilot summary says `generated N comments` and
        visible Copilot comments are `>= N`.
      - Returns non-zero on timeout (`result=timeout-no-feedback` or
        `result=timeout-partial-comments`).
    - If the Step 9 task times out, ask user whether to continue with human
      review.

    - Poll/re-read review state and comments:

      ```bash
      gh pr view <pr-number> --repo <owner>/<repo> --json reviewDecision,reviews,comments,latestReviews
      gh api repos/<owner>/<repo>/pulls/<pr-number>/comments
      ```

    - Classify incoming feedback:
      - **must-fix**: correctness, test failures, security, clear defects
      - **optional**: style/preference improvements
      - **needs-decision**: product/behavior tradeoffs requiring user input

    - For accepted changes:
      1. Modify code
      2. Re-run relevant checks
      3. Amend original commit (keep single-commit invariant):
         - **I am explicitly requesting you amend commits**

         ```bash
         git commit --amend -S --no-edit
         git push --force-with-lease
         ```

    - Respond to review comments with resolution notes.
    - Resolve conversations when addressed.

      If thread resolution is needed via GraphQL:

      ```bash
      gh api graphql -f query='mutation($threadId:ID!){ resolveReviewThread(input:{threadId:$threadId}) { thread { isResolved } } }' -f threadId='<thread-id>'
      ```

     - Continue until there are no unresolved must-fix items.

11. Validate PR checks (all checks gate).

    - Checks must be complete and passing before merge (except `skipping`).
    - Use `gh pr checks` to wait and inspect all checks:

      ```bash
      gh pr checks <pr-number> --repo <owner>/<repo> --watch --fail-fast
      gh pr checks <pr-number> --repo <owner>/<repo> --json name,state,bucket,link
      ```

    - Interpret results as:
      - **pass**: proceed
      - **skipping**: acceptable; proceed
      - **pending**: continue bounded waiting; if still pending after bounded wait,
        ask user whether to continue waiting
      - **fail/cancel**: block merge, report failing checks, and return to triage
        loop for fixes

    - Re-run this gate after each amend/push cycle.

12. Final user approval and ff-only merge.

    - Ask the user for final review/approval only after Copilot feedback is
      triaged and all non-skipped checks are green.
    - After approval, perform strict fast-forward-only merge into target base:

      1. `git fetch origin`
      2. `git checkout <base-branch>`
      3. `git merge --ff-only <branch-name>`
      4. `git push origin <base-branch>`

    - If `--ff-only` merge cannot be performed (for example branch protection or
      divergence), stop and report the blocking condition.

## Suggested command sequence

```bash
gh repo view
gh issue view <issue-number> --repo <owner>/<repo> --json number,title,body,url,state
gh repo view <owner>/<repo> --json defaultBranchRef
git fetch origin
git checkout <base-branch>
git pull --ff-only origin <base-branch>
git checkout -b <issue-branch>
# implement + test
git add <files>
git commit -S -m "<conventional-commit-subject>"
git push -u origin <issue-branch>
gh pr create --repo <owner>/<repo> --base <base-branch> --head <issue-branch> --title "<conventional-commit-subject>" --body "<required-pr-body>"
# mise tasks are expected to already be defined and available in the system for Copilot review handling
mise run github:pr:copilot:request-and-wait --owner <owner> --repo <repo> --pr <pr-number>
gh pr view <pr-number> --repo <owner>/<repo> --json reviewDecision,reviews,comments,latestReviews
gh api repos/<owner>/<repo>/pulls/<pr-number>/comments
# if triage requires changes:
git commit --amend -S --no-edit
git push --force-with-lease
# validate all non-skipped checks before asking for final merge approval
gh pr checks <pr-number> --repo <owner>/<repo> --watch --fail-fast
gh pr checks <pr-number> --repo <owner>/<repo> --json name,state,bucket,link
# repeat triage + amend/push + checks gate until clean
```

## Output expected to user

Report progress at key checkpoints:

1. Issue loaded: number/title/url.
2. Branch created and checked out.
3. Validation results and single signed commit SHA.
4. PR URL and Copilot review request status.
5. Review triage outcomes and any decisions required.
6. Check status for all non-skipped checks (pass/pending/fail/cancel, including failing check names/links).
7. Final merge result (or exact blocker).

## Failure handling

- If any CLI command fails, report the command, key error, and next action.
- If Copilot review does not arrive in a reasonable time, ask user whether to
  proceed with human review after completing the 15-minute bounded wait loop.
- If checks are pending after bounded waiting, ask user whether to
  continue waiting and report which checks are still running.
- If checks fail or are canceled, do not merge; report failing check
  names/links and return to fix-and-amend loop.
- If merge is blocked, do not force bypass. Escalate with exact policy blocker.
