---
name: create-github-issue
description: Creates a well-structured GitHub issue with Motivation, Acceptance Criteria, and optional References sections using the GitHub MCP server. Use when the user asks to create, file, or open a GitHub issue.
metadata:
  author: Zach Callahan
  version: "1.0"
---

# Create GitHub Issue

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

## Title generation

Generate the issue title from the Motivation content. The title should be:

- Concise (under 80 characters when possible)
- Descriptive enough to convey the issue at a glance
- Written in imperative mood (e.g., "Add pagination to user list endpoint")

## Steps

1. Determine the target repository (`owner`/`repo`).
2. Draft the Motivation, Acceptance Criteria, and References (if any) based on
   user input.
3. Generate a concise, descriptive title from the Motivation.
4. Present the draft title and body to the user for confirmation before
   creating.
5. Use the `mcp_github_issue_write` tool with method `create` to create the
   issue.
6. Report the created issue number and URL back to the user.

## Labels and assignees

If the user specifies labels or assignees, include them in the
`mcp_github_issue_write` call. Do not add labels or assignees unless requested.
