---
name: read-github-pr
description: Reads a GitHub pull request and summarizes its description, status, commits, changed files, and discussion comments using the GitHub CLI (`gh`). Use when the user asks to review, inspect, or summarize a PR.
metadata:
  author: Zach Callahan
  version: "1.0"
---

# Read GitHub PR (gh CLI)

## When to use this skill

Use this skill when the user asks to read, summarize, inspect, or review a pull
request and its comments.

## Required information

Before reading the PR, gather:

1. **Repository**: `owner/repo` (infer from git remote when possible).
2. **PR identifier**: PR number or full PR URL.

If either value is missing and cannot be inferred, ask for the missing input.

## Steps

1. Determine repository and PR number.

   - If in repo context, verify with:

     ```bash
     gh repo view
     ```

   - If not in repo context, use `--repo <owner>/<repo>`.

2. Read the PR metadata and body:

   ```bash
   gh pr view <pr-number> --repo <owner>/<repo> \
     --json number,title,author,state,isDraft,baseRefName,headRefName,body,url,mergeable,reviewDecision,statusCheckRollup,commits,files
   ```

3. Read review comments (inline code review comments):

   ```bash
   gh api repos/<owner>/<repo>/pulls/<pr-number>/comments
   ```

4. Read PR conversation comments (non-inline discussion):

   ```bash
   gh api repos/<owner>/<repo>/issues/<pr-number>/comments
   ```

5. Summarize results for the user with this structure:

   ```markdown
   ## PR Overview

   - Title, author, state, draft status
   - Base/head branches
   - Mergeability and checks/review decision

   ## Change Summary

   - Short explanation of what changed and why
   - Notable files touched
   - Commit highlights

   ## Discussion

   - Open questions or unresolved review threads/comments
   - Key decisions captured in comments

   ## Links

   - PR URL
   ```

## Notes

- Prefer factual summaries and quote exact commenter concerns when useful.
- If there are many comments, group by theme (tests, API shape, naming, etc.).
- Do not post comments or modify the PR unless explicitly asked.
