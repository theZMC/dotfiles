---
name: work-github-issue
description: |
  Works a GitHub issue end-to-end using gh CLI: reads issue, creates branch,
  implements changes, creates one signed conventional commit, opens PR with
  close semantics, requests @copilot review, triages feedback by amending,
  and performs final ff-only merge after user approval.
metadata:
  author: Zach Callahan
  version: "1.1"
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
   - Use `--repo <owner>/<repo>` consistently when needed.

2. Read issue details.

   - `gh issue view <issue-number> --repo <owner>/<repo> --json number,title,body,url,state,labels,assignees`
   - If issue is closed or inaccessible, stop and report the reason.

3. Determine base branch and ensure local sync.
   - `gh repo view --repo <owner>/<repo> --json defaultBranchRef`
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

9. Request Copilot review.
   - Use exactly:
     `gh pr edit <pr-number> --repo <owner>/<repo> --add-reviewer @copilot`
   - **Critical:** reviewer must be `@copilot` with leading `@`; `copilot`
     without `@` is not equivalent.
   - If this fails because Copilot review is unavailable, report clearly and ask
     user whether to continue without Copilot.

10. Review triage loop.

    - After requesting `@copilot`, wait for Copilot-authored feedback using a
      bounded sleep loop (total wait cap: 15 minutes).

      Use these sleep intervals (seconds):

      ```text
      30 60 120 180 240 270
      ```

      Detection rule:

      - Parse latest Copilot review summary from `/pulls/<pr>/reviews`.
      - If summary says `generated no comments`, treat feedback as arrived.
      - If summary says `generated N comment` or `generated N comments`, wait
        until visible Copilot review comments in `/pulls/<pr>/comments` are
        `>= N`.

      Reference polling snippet:

      ```bash
      owner=<owner>
      repo=<repo>
      pr=<pr-number>
      is_copilot_user='(.user.login|ascii_downcase) as $u | $u=="copilot" or $u=="copilot-pull-request-reviewer[bot]"'
      copilot_expected_comments() {
        gh api "repos/$owner/$repo/pulls/$pr/reviews" --jq \
          "([.[] | select($is_copilot_user)] | last | .body // \"\") as \$b
          | if (\$b|test(\"generated no comments\";\"i\")) then 0
            elif (\$b|test(\"generated [0-9]+ comment(s)?\";\"i\")) then (\$b|capture(\"generated (?<n>[0-9]+) comment(s)?\";\"i\").n|tonumber)
            else -1 end"
      }
      copilot_visible_comments() {
        gh api "repos/$owner/$repo/pulls/$pr/comments" --jq \
          "[.[] | select($is_copilot_user)] | length"
      }

      for s in 30 60 120 180 240 270; do
        expected=$(copilot_expected_comments)
        if [ "$expected" -eq 0 ]; then
          break
        elif [ "$expected" -gt 0 ]; then
          visible=$(copilot_visible_comments)
          [ "$visible" -ge "$expected" ] && break
        fi
        sleep "$s"
      done
      ```

      Quick verification commands:

      ```bash
      owner=BridgePhase repo=ccm pr=142 # no Copilot review yet -> expected=-1
      owner=BridgePhase repo=ccm pr=266 # Copilot says 2 comments -> expected=2, visible=2
      ```

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

Use this as a compact checklist (Step 10 contains the canonical Copilot wait
helper; do not duplicate it elsewhere):

```bash
gh repo view
gh issue view <issue-number> --repo <owner>/<repo> --json number,title,body,url,state
gh repo view --repo <owner>/<repo> --json defaultBranchRef
git fetch origin
git checkout <base-branch>
git pull --ff-only origin <base-branch>
git checkout -b <issue-branch>
# implement + test
git add <files>
git commit -S -m "<conventional-commit-subject>"
git push -u origin <issue-branch>
gh pr create --repo <owner>/<repo> --base <base-branch> --head <issue-branch> --title "<conventional-commit-subject>" --body "<required-pr-body>"
# critical: reviewer must be exactly @copilot (include '@')
gh pr edit <pr-number> --repo <owner>/<repo> --add-reviewer @copilot
# run Step 10 Copilot wait helper
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
  proceed with human review after completing the 15-minute bounded wait loop.
- If merge is blocked, do not force bypass. Escalate with exact policy blocker.
