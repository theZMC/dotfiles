---
name: work-github-issue
description: Works a GitHub issue end-to-end using gh CLI: reads issue, creates branch, implements changes, creates one signed conventional commit, opens PR with close semantics, requests @copilot review, triages feedback by amending, and performs final ff-only merge after user approval.
metadata:
  author: Zach Callahan
  version: "1.0"
---

# Work GitHub Issue (gh CLI)

## When to use this skill

Use this skill when the user asks to implement a GitHub issue from start to
finish, including branch creation, coding, PR creation, Copilot review
triage, and final merge.

## Required information

Before starting, gather:

1. **Issue identifier**: issue number or full issue URL.
2. **Repository**: `owner/repo` (infer from current git remote when possible).
3. **Target base branch** (optional): if not provided, use repository default.

If the issue identifier is missing and cannot be inferred, ask for it.

## Preconditions

- `gh` is authenticated and has access to the repository.
- `gh` CLI is version `2.88.0+` (for `@copilot` reviewer support).
- GPG signing is already configured in git.
- Local working tree is clean before branch creation.

If the working tree is dirty, stop and ask the user how to proceed.

## Guardrails

- Prompt the user only when truly blocked by ambiguity or a required decision.
- Do not paste the issue body into commit messages or PR body.
- Create exactly one commit for the issue; maintain that invariant throughout
  review by amending the original commit.
- Use `--force-with-lease` (never `--force`) when updating the remote branch
  after amending.
- Do not merge until the user gives final approval.

## Branch naming

Generate branch name as:

```text
<issue-number>-<slugified-issue-title>
```

Slug rules:

- Lowercase ASCII.
- Replace non-alphanumeric runs with `-`.
- Collapse repeated dashes.
- Trim leading/trailing dashes.
- Limit to a practical length (for example, 60 chars for slug part).

If the branch already exists, append a short numeric or timestamp suffix.

## Conventional commit rules

- Use one signed commit with `git commit -S`.
- Subject must be a valid conventional commit, for example:
  `feat(auth): add session refresh endpoint`.
- Commit message must be a single subject line only:
  - no body
  - no footer
  - no pasted issue content

## PR body format

Use this exact structure:

```markdown
Closes #<issue-number>

## Summary

- <change 1>
- <change 2>
- <change 3>
```

- PR title must exactly match the commit subject.
- Keep summary concise and implementation-focused.

## Steps

1. Resolve repo and issue context.

   - Confirm repository context:

     ```bash
     gh repo view
     ```

   - If needed, use explicit `--repo <owner>/<repo>` for all `gh` commands.

2. Read issue details.

   - Preferred:

     ```bash
     gh issue view <issue-number> --repo <owner>/<repo> --json number,title,body,url,state,labels,assignees
     ```

   - If issue is closed or inaccessible, stop and report the reason.

3. Determine base branch and ensure local sync.

   - Resolve default branch:

     ```bash
     gh repo view --repo <owner>/<repo> --json defaultBranchRef
     ```

   - Fetch remotes and ensure local base is up to date before branching.

4. Create and check out the issue branch.

   - Branch from latest base branch tip.
   - Create the generated branch name and check it out.

5. Implement the issue.

   - Work directly from issue requirements.
   - Ask questions only for ambiguities that materially change behavior.
   - Run relevant tests/validation before commit.

6. Create a single signed conventional commit.

   - Stage all intended files.
   - Create one signed commit:

     ```bash
     git commit -S -m "<conventional-commit-subject>"
     ```

   - Verify only one commit exists on top of base.

7. Push branch.

   ```bash
   git push -u origin <branch-name>
   ```

8. Open PR targeting default branch.

   - Create PR with title exactly equal to commit subject.
   - Use required body format with `Closes #<issue-number>` and summary bullets.
   - Prefer heredoc-safe body creation.

   Example:

   ```bash
   gh pr create --repo <owner>/<repo> --base <base-branch> --head <branch-name> --title "<commit-subject>" --body "$(cat <<'EOF'
   Closes #<issue-number>

   ## Summary

   - <change 1>
   - <change 2>
   EOF
   )"
   ```

9. Request Copilot review.

   - Use:

     ```bash
     gh pr edit <pr-number> --repo <owner>/<repo> --add-reviewer @copilot
     ```

   - If this fails because Copilot review is unavailable, report clearly and ask
     user whether to continue without Copilot.

10. Review triage loop.

    - Poll/re-read review state and comments:

      ```bash
      gh pr view <pr-number> --repo <owner>/<repo> --json reviewDecision,reviews,comments,latestReviews
      gh api repos/<owner>/<repo>/pulls/<pr-number>/comments
      gh api repos/<owner>/<repo>/issues/<pr-number>/comments
      ```

    - Classify incoming feedback:
      - **must-fix**: correctness, test failures, security, clear defects
      - **optional**: style/preference improvements
      - **needs-decision**: product/behavior tradeoffs requiring user input

    - For accepted changes:
      1. Modify code
      2. Re-run relevant checks
      3. Amend original commit (keep single-commit invariant):

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

11. Final user approval and ff-only merge.

    - Ask the user for final review/approval once Copilot feedback is triaged.
    - After approval, perform strict fast-forward-only merge into target base:

      1. `git fetch origin`
      2. `git checkout <base-branch>`
      3. `git merge --ff-only <branch-name>`
      4. `git push origin <base-branch>`

    - If `--ff-only` merge cannot be performed (for example branch protection or
      divergence), stop and report the blocking condition.

## Suggested command sequence

Use this as an execution checklist:

```bash
gh repo view
gh issue view <issue-number> --repo <owner>/<repo> --json number,title,body,url,state
gh repo view --repo <owner>/<repo> --json defaultBranchRef
git status --short
git fetch origin
git checkout <base-branch>
git pull --ff-only origin <base-branch>
git checkout -b <issue-branch>
# implement + test
git add <files>
git commit -S -m "<conventional-commit-subject>"
git push -u origin <issue-branch>
gh pr create --repo <owner>/<repo> --base <base-branch> --head <issue-branch> --title "<conventional-commit-subject>" --body "$(cat <<'EOF'
Closes #<issue-number>

## Summary

- <change 1>
EOF
)"
gh pr edit <pr-number> --repo <owner>/<repo> --add-reviewer @copilot
# triage loop:
gh pr view <pr-number> --repo <owner>/<repo> --json reviewDecision,reviews,comments,latestReviews
gh api repos/<owner>/<repo>/pulls/<pr-number>/comments
git commit --amend -S --no-edit
git push --force-with-lease
```

## Output expected to user

Report progress at key checkpoints:

1. Issue loaded: number/title/url.
2. Branch created and checked out.
3. Validation results and single signed commit SHA.
4. PR URL and Copilot review request status.
5. Review triage outcomes and any decisions required.
6. Final merge result (or exact blocker).

## Failure handling

- If any CLI command fails, report the command, key error, and next action.
- If Copilot review does not arrive in a reasonable time, ask user whether to
  continue waiting or proceed with human review.
- If merge is blocked, do not force bypass. Escalate with exact policy blocker.
