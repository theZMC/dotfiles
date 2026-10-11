# Wind-Down Report

## Checklist

1. Scouts told to stop; each backlog finalized (fixed / rejected / open).
2. In-flight PRs either merged with approval or parked with a status line.
3. Worktrees, throwaway containers, agent sessions (browser, tmux), app
   processes, simulators, and temp config dirs cleaned up by name.
4. Shared environment (server or built artifact) on the latest main, or its
   state written down.
5. Report compiled and sent to the user (as a shareable doc or file).

## Report outline

```markdown
# {Project} iteration round, {date}

## Summary

- {n} findings decided, {m} PRs merged, {k} follow-up issues filed.
- Lenses covered: {personas or audit themes}.
- One-paragraph takeaway: biggest wins and the biggest remaining risk.

## Merged PRs

### {Area or persona}

| PR  | Title | Finding | Severity |
| --- | ----- | ------- | -------- |

## Open findings (not yet submitted)

### {Persona or lens}

| Rank | Title | Where | Severity | Evidence |
| ---- | ----- | ----- | -------- | -------- |

## Follow-up issues filed

| Issue | Title | Why deferred |
| ----- | ----- | ------------ |

## Open PRs

| PR  | Status | Blocker |
| --- | ------ | ------- |

## Manual steps agents can't do

- {from the profile's manual-only list, e.g. a real screen-reader pass;
  physical devices; email deliverability; other terminal emulators; HiDPI and
  multi-monitor; signing and notarisation}

## Known flakes

- {test or job}: {evidence and triage verdict}

## Leftover test data

- {accounts, records, uploads created during the round, and how to remove them}

## Environment state

- Shared environment at {sha}; services running or artifact path: {list};
  ports in use: {list}.
- Leftover processes, tmux sessions, windows, or simulators: {list or none}.
- Anything that needs a restart, migration, or cleanup.

## Decisions and preferences recorded

- {durable preferences saved to memory this round}
```
