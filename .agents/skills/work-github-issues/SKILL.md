---
name: work-github-issues
description: Use when the user wants to work multiple GitHub issues serially with subagents, wrapping `work-github-issue` for dependency-aware orchestration, PRs, checks, and approved merges.
metadata:
  author: Zach Callahan
  version: "1.0"
---

# Work GitHub Issues

## Use When

Use this skill when the user wants a set of GitHub issues worked by subagents,
especially after issues were generated from a plan. This is a lightweight
orchestration wrapper around `work-github-issue`.

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
     `work-github-issue` worker.
   - If the user does not explicitly approve merges, workers must stop after PR
     checks and report back for approval.

Ask one concise clarifying question only when the repository, issue set, or
merge policy cannot be inferred.

## Core Rule

The coordinator does not implement issue work directly. It launches or resumes
subagents, and each issue worker uses the `work-github-issue` skill for its own
branch, implementation, validation, PR, Copilot triage, checks, and merge policy.

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

Build the order from GitHub dependency links when available:

```bash
gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner,name:$repo){ issue(number:$number){ number blockedBy(first:20){ nodes { number title url } } } } }' -f owner='<owner>' -f repo='<repo>' -F number=<issue-number>
```

Ordering rules:

- Treat `blocked by` links as hard dependencies.
- Treat tracker issue order as a soft dependency when no hard dependency exists.
- Put tracker verification or closure last.
- If dependency data contains a cycle, stop and report the exact conflict.

## Coordinator Loop

For each issue:

1. Mark the issue `in_progress` in the coordinator todo list.
2. Launch a `general` subagent with the worker prompt below.
3. Wait for the worker result.
4. If the worker completed, record the branch, PR URL, commit SHA, validation,
   merge or approval status, and follow-up risks.
5. If the worker returns a continuation state or the user interrupts, resume the
   same `task_id`.
6. If a technical intervention is needed, use a subagent. Do not repair the
   issue branch directly in the coordinator context.
7. If a product decision is required, stop and ask the user one concise question.
8. Start the next issue only after the previous write-capable worker has
   completed, stopped safely, or been explicitly abandoned by the user.

## Worker Prompt

Use this template for each issue worker:

```text
You are the issue worker for <owner>/<repo> issue #<number> only.
Use the `work-github-issue` skill and follow it end-to-end.

Repository: <owner>/<repo>. Base branch: <base>. Working directory: <path>.

Merge policy: <state whether the user explicitly approved final merge, or that
the worker must stop before merge and report the PR for approval>.

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
commit SHA, validation performed, merge or approval status, and follow-up risks.
```

## Intervention Policy

Use or resume a subagent for any intervention, including:

- main moved ahead of the feature branch,
- checks failed,
- Copilot found must-fix feedback,
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
- tracker closure status,
- validation gates verified,
- blockers or follow-up risks.

Avoid replaying subagent logs.
