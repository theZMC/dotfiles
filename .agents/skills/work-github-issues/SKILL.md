---
name: work-github-issues
description: Use when the user wants to work multiple GitHub issues serially with subagents, wrapping `work-github-issue`, coordinating local review subagents unless Copilot review is explicitly requested, and managing dependency-aware PRs, checks, and approved merges.
metadata:
  author: Zach Callahan
  version: "1.4"
---

# Work GitHub Issues

## Use When

Use this skill when the user wants a set of GitHub issues worked by subagents,
especially after issues were generated from a plan. This is a lightweight
orchestration wrapper around `work-github-issue` with a local review phase by
default.

Common request forms:

```text
/work-github-issues #101 #102 #103
```

```text
/work-github-issues tracker #120
```

```text
/work-github-issues the issues we just created; subagents are clear to merge
```

## Required Input

1. A repository, inferred from the current git remote when possible.
2. A work set, inferred from one of:
   - explicit issue numbers or URLs,
   - issues created earlier in the conversation,
   - a tracker issue,
   - a GitHub Project query requested by the user.
3. A merge policy:
   - If the user explicitly approves merges, pass that approval to each
     `work-github-issue` worker after the review path clears.
   - If the user does not explicitly approve merges, workers must stop after PR
     checks and report back for approval.
4. A review preference:
   - If the invocation explicitly requests Copilot review, pass that request to
     each `work-github-issue` worker and skip local review subagents unless the
     user also explicitly requests local review.
   - Otherwise, do not request Copilot. Run a local review subagent for each PR
     before final merge.

Ask one concise clarifying question only when the repository, issue set, or
merge policy cannot be inferred. Do not ask about review preference when it is
omitted; default to local review and no Copilot.

## Core Rule

The coordinator does not implement issue work directly. It launches or resumes
subagents, and each issue worker uses the `work-github-issue` skill for its own
branch, implementation, validation, PR, checks, and merge policy. Copilot triage
happens only when the invocation explicitly requested Copilot review. Otherwise,
the coordinator runs a local read-only review subagent before final merge.

## Issue Discovery

Resolve the repository first:

```bash
gh repo view --json nameWithOwner,defaultBranchRef,url
```

Discover issues in this order:

1. Explicit issue numbers or URLs from the request.
2. Issues created earlier in the current conversation.
3. Issue links from a named tracker issue.
4. GitHub Project items if the user names a project.

Read every candidate issue before sequencing:

```bash
gh issue view <number> --repo <owner>/<repo> --json number,title,body,url,state,id
```

Skip closed issues unless the user explicitly asks to verify or close a tracker.

## Sequencing

Default to serial execution. Do not run multiple write-capable issue workers in
the same working tree at the same time.

Build the order from GitHub dependency links when available. The
`github:issue:blocked-by:list` task returns an issue's blockers as a JSON array
(`[]` when none), with transient-failure retries:

```bash
mise run github:issue:blocked-by:list --repo <owner>/<repo> --issue <number>
```

Ordering rules:

- Treat `blocked by` links as hard dependencies.
- Treat tracker issue order as a soft dependency when no hard dependency exists.
- Put tracker verification or closure last.
- If dependency data contains a cycle, stop and report the exact conflict.

## Review Mode

At the start, classify the invocation:

- **Copilot review requested**: the user explicitly asks for Copilot review,
  Copilot reviewer, or `@copilot` triage. Pass this through to workers and do
  not launch local review subagents unless the user explicitly asked for both.
- **Local review default**: any other request, including generic "review" or no
  review mention. Do not request Copilot. Run local review subagents.

When local review is active, keep final merge approval in the coordinator until
the local review path clears. Even if the user pre-approved merges, the first
worker run must stop as soon as the PR is open and pushed, without waiting for
PR checks to settle, and report the PR for coordinator review. Local review then
runs in parallel with PR checks. After local review clears, resume the original
issue worker with final merge approval if the user already approved merges; the
resumed worker waits for checks before merging.

## Review Skill Discovery

Do this only in local review mode, and only from skill metadata.

- Use the available-skills metadata already visible to the coordinator when
  possible.
- If filesystem discovery is needed, read only the frontmatter of `SKILL.md`
  files in configured skill directories; do not read skill bodies.
- Do not call the `skill` tool in the coordinator for review-skill discovery.
- Treat a skill as a review candidate only when its name or description says it
  can critique, validate, test, inspect implementation quality, exercise UI/UX,
  assess architecture, assess security, or otherwise review a change.
- Ignore skills whose metadata only says they create/read/summarize GitHub
  artifacts, orchestrate work, or hand off context.
- For each issue, choose at most one primary review skill by matching the issue
  title/body, PR file list, and candidate metadata. Prefer the most specific fit.
- If the PR file list is not in the worker result, fetch only PR metadata such
  as `gh pr view <pr-number> --repo <owner>/<repo> --json title,body,files` for
  selection; do not pull the full diff just to choose a skill.
- Pass the chosen skill name and metadata description to the review subagent.
  The review subagent may load and use that selected skill in its own context.
- If no review skills are available or none fit the issue, launch the review
  subagent with the ad-hoc review prompt below instead.

## Coordinator Loop

For each issue:

1. Mark the issue `in_progress` in the coordinator todo list.
2. Launch a `general` subagent with the worker prompt below.
3. Wait for the worker result.
4. If the worker completed, record the branch, PR URL, commit SHA, validation,
   merge or approval status, review status, and follow-up risks.
5. If local review mode is active and the worker returned a PR URL, choose a
   review skill from metadata and launch a read-only `general` review subagent
   with the review prompt below. PR checks may still be running at this point,
   but the review subagent must not inspect, wait on, or reason from GitHub
   checks, CI logs, or test validation status. The review subagent validates PR
   fit and code/doc quality only; the issue worker owns test execution, PR check
   waiting, and final gate handling.
6. If the review subagent returns must-fix findings, resume the original issue
   worker with the findings. The worker fixes, validates, amends, pushes with
   `--force-with-lease`, and returns an updated status. Re-run local review only
   when the fixes materially changed behavior, control flow, architecture, or the
   prior review found real must-fix issues. Cap local review at 3 rounds.
7. If local review clears and the user already approved merges, resume the
   original issue worker with final merge approval. The resumed worker waits for
   PR checks to settle before merging. Otherwise report the PR for approval.
8. If the worker returns a continuation state or the user interrupts, resume the
   same `task_id`.
9. If a technical intervention is needed, use a subagent. Do not repair the
   issue branch directly in the coordinator context.
10. If a product decision is required, stop and ask the user one concise question.
11. Start the next issue only after the previous issue's worker, local review
    path, and merge/approval handoff have completed, stopped safely, or been
    explicitly abandoned by the user.

## Worker Prompt

Use this template for each issue worker:

```text
You are the issue worker for <owner>/<repo> issue #<number> only.
Use the `work-github-issue` skill and follow it end-to-end.

Repository: <owner>/<repo>. Base branch: <base>. Working directory: <path>.

Copilot review: <state whether Copilot review was explicitly requested. If not
requested, say: "Do not request Copilot review.">

Coordinator local review: <state whether local review is enabled. If enabled,
say: "Stop and return as soon as the PR is open and pushed. Do NOT wait for PR
checks to settle — the coordinator will run local review in parallel with checks.
If later resumed with review findings, fix them through the normal amend flow.
If later resumed with final merge approval, then wait for checks and merge only
when all gates pass.">

Merge policy: <state whether the user explicitly approved final merge, or that
the worker must stop before merge and report the PR for approval. In local review
mode, pre-approved merge means approval applies only after local review clears,
and the worker still hands back immediately after PR creation rather than waiting
for checks>.

Context:
- <completed prerequisite issues>
- <tracker or project constraints>
- <expected validation gates>

Rules:
- If the working tree is dirty before you start, stop and return the exact
  blocker.
- If the base branch moves or the feature branch needs a normal update, handle
  it yourself when safe.
- If final ff-only merge is blocked, stop and report exactly why.
- Ask for user input only for true product or behavior decisions.
- Do not ask the user directly from the subagent. Return blockers to the
  coordinator.

Return only a concise final status with: issue number/title, branch, PR URL,
commit SHA, local validation performed (note that PR checks may still be running
if you handed back early in local review mode), Copilot/local review status,
merge or approval status, and follow-up risks.
```

## Review Prompt

Use this template for each local review subagent:

```text
You are the local PR reviewer for <owner>/<repo> issue #<number> only.
Review PR <pr-url> for correctness, regressions, missing tests, security risks,
and maintainability risks.

Repository: <owner>/<repo>. Base branch: <base>. Working directory: <path>.

Selected review skill: <skill-name and metadata description, or "none">.

If a selected review skill is provided, load and use `<skill-name>` in your own
subagent context. Apply it as the main review lens, but keep the output PR-focused
and actionable. Do not load unrelated skills. If the selected skill is
unavailable, fall back to the ad-hoc review path and mention that in the result.

If no selected review skill is provided, perform a best-effort ad-hoc review:
inspect the issue, PR metadata, changed files, diff, and relevant test files
using available read-only commands and file reads.

Review boundary: your job is to decide whether the PR fits the issue and whether
the code/docs introduce correctness, contract, security, maintainability, or
missing-test risks. Do not inspect GitHub check status, CI logs, workflow runs,
or test validation results. Do not run test suites, linters, builds, typechecks,
or other validation commands unless a specific code-level concern cannot be
understood from the diff and file reads. The implementation worker owns all test
execution, PR check waiting, CI failure triage, and final gate handling.

Rules:
- Read-only review only. Do not edit files, commit, push, merge, or request
  Copilot review.
- Ignore GitHub checks and CI entirely. Do not wait for PR checks to settle,
  snapshot check status, read CI logs, inspect workflow runs, or diagnose check
  failures. The worker will gate the final merge on checks.
- Do not ask the user directly. Return blockers or decisions to the coordinator.
- Prefer high-signal findings over broad commentary.
- Treat correctness, data loss, security, broken tests, missing critical tests,
  and behavioral regressions as must-fix.
- Treat style, naming, and low-risk polish as optional.

Return only:
- selected skill used, or ad-hoc review,
- must-fix findings with file/line references when possible,
- optional findings,
- validation commands run only if strictly necessary to investigate a specific
  code-level concern; otherwise state that validation/checks were intentionally
  not inspected because the worker owns them,
- clear recommendation: "resume worker for fixes" or "local review cleared".
```

## Intervention Policy

Use or resume a subagent for any intervention, including:

- main moved ahead of the feature branch,
- checks failed,
- a local review subagent or Copilot found must-fix feedback,
- ff-only merge is blocked,
- branch or PR state became stale,
- GitHub Project or dependency metadata needs repair,
- a worker was interrupted.

Prefer resuming the original issue worker by `task_id` when that worker owns the
branch context.

## Tracker Issues

When the work set has an overarching tracker issue:

1. Work all child issues first.
2. Launch a final tracker subagent.
3. Have it verify child issue states, merged PRs, and required validation gates.
4. If no repository change remains, close the tracker directly with a concise
   completion comment.
5. Do not create empty commits or empty PRs for tracker-only closure.

## Final Report

Summarize only the useful outcome:

- issues completed and PRs merged or awaiting approval,
- local review status, or Copilot review status when explicitly requested,
- tracker closure status,
- validation gates verified,
- blockers or follow-up risks.

Avoid replaying subagent logs.
