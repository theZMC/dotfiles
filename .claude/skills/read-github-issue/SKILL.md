---
name: read-github-issue
description: Reads a GitHub issue and reports its status, metadata, linked development, and discussion comments using the GitHub CLI (`gh`) without summarizing the issue body content. Use when the user asks to review, inspect, or summarize an issue.
metadata:
  author: Zach Callahan
  version: "1.0"
---

# Read GitHub Issue (gh CLI)

## When to use this skill

Use this skill when the user asks to read, summarize, inspect, or review a
GitHub issue and its comments.

## Required information

Before reading the issue, gather:

1. **Repository**: `owner/repo` (infer from git remote when possible).
2. **Issue identifier**: Issue number or full issue URL.

If either value is missing and cannot be inferred, ask for the missing input.

## Steps

1. Determine repository and issue number.

   - If in repo context, verify with:

     ```bash
     gh repo view
     ```

   - If not in repo context, use `--repo <owner>/<repo>`.

2. Read issue metadata and body:

   ```bash
   gh issue view <issue-number> --repo <owner>/<repo> \
     --json number,title,author,state,labels,assignees,milestone,body,url,createdAt,updatedAt,closedAt,comments,projectItems
   ```

3. Read issue conversation comments (includes author, body, timestamps):

   ```bash
   gh api repos/<owner>/<repo>/issues/<issue-number>/comments
   ```

4. Check linked development context (if relevant), such as branch or PR linkage:

   ```bash
   gh issue view <issue-number> --repo <owner>/<repo> --json closingIssuesReferences
   ```

5. Report results for the user with this structure:

   ```markdown
   ## Issue Overview

   - Title, author, state
   - Labels, assignees, milestone
   - Created/updated/closed timestamps

   ## Issue Content

   - Provide the issue body as-is (verbatim), preserving markdown
   - Do not summarize, reinterpret, or rewrite the issue body

   ## Discussion

   - Key questions, decisions, and blockers from comments
   - Outstanding follow-ups or unresolved threads

   ## Linked Work

   - Related pull requests, branches, or references

   ## Links

   - Issue URL
   ```

## Notes

- Do not summarize the issue body; include it verbatim when requested.
- Prefer factual summaries and quote exact commenter concerns when useful.
- If there are many comments, group by theme (scope, priority, implementation,
  testing, ownership).
- Call out stale issues (for example, no updates in a long period) when relevant.
- Do not post comments or modify the issue unless explicitly asked.
