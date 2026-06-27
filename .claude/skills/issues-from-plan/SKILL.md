---
name: issues-from-plan
description: Decomposes an LLM-generated plan into a set of GitHub issues, then files each one by invoking the `create-github-issue` skill. Use when the user has a plan and wants it filed as actionable, agent-workable issues.
metadata:
  author: Zach Callahan
  version: "1.1"
---

# Issues From Plan

Split the plan into one issue per independently shippable unit of work,
then file the batch by invoking `create-github-issue`.

Each issue's Motivation and Acceptance Criteria must carry enough context
from the plan — concrete files/functions/behaviors, constraints the plan
locked in (libraries, flags, conventions), and explicit out-of-scope
notes — that an agent picking it up cold can work it end-to-end and
produce a PR matching the plan's intent.

If the user named a GitHub Project, pass it through to
`create-github-issue` verbatim. It resolves the project by fuzzy name or number
(via the `github:project:status:set` mise task), so an approximate project name
is fine — no need to look up the exact title first.
