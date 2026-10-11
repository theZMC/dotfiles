---
name: progressive-iteration
description: >
  Runs a coordinator-led find, triage, fix, review, merge loop with subagents:
  scouts (explorers) find issues one at a time, the user decides each one, an
  implementer fixes it in an isolated worktree with before/after evidence, an
  independent reviewer checks the PR, and the coordinator merges only with the
  user's approval. Works for any development effort: web apps (dogfooding by
  persona), TUIs, desktop and mobile GUI apps, CLIs, libraries, infrastructure,
  or docs. Use whenever the user asks
  to "run a dogfood/review/QA loop with subagents", "coordinate agents to find
  and fix issues iteratively", "find, triage, fix, review, merge", "progressive
  iteration", "have agents explore the app and fix what they find", or wants a
  swarm of agents auditing and improving a project while they steer, even if
  they don't name this skill.
disable-model-invocation: true
metadata:
  author: Zach Callahan
  version: "1.1"
---

# Progressive Iteration

## Use When

Use this skill when the user wants a project improved in rounds by a team of
subagents while they steer the decisions. The user stays in the loop on every
finding, but never has to manage the agents themselves.

Common request forms:

```text
/progressive-iteration dogfood the app as each persona, admin first
```

```text
Run a QA loop with subagents on the CLI. Find, triage, fix, review, merge.
```

```text
Dogfood the TUI as a new user and a power user. Find, triage, fix, review, merge.
```

```text
Coordinate agents to audit the Terraform modules and fix what they find. I'll
check in from my phone.
```

## Core Rule

The main agent is a pure coordinator. It delegates every action, including
reads, builds, screenshots, and git work, to subagents. It keeps its own context
for decisions, sequencing, and talking to the user.

This matters because the loop runs for hours. A coordinator that reads diffs,
logs, or transcripts fills its context and starts forgetting user decisions and
in-flight state. Rely on agent reports. Never read subagent transcripts.

The one exception is the final merge command, which the coordinator runs itself
after explicit user approval (see [Merge](#merge)).

## Required Input

Infer what you can from the repo and conversation. Ask one concise question only
for what you can't infer:

1. **Target and scope.** What is being explored: a web app, a TUI, a desktop
   or mobile GUI app, a CLI, a library, an infra stack, a docs site.
2. **Target profile and drive method.** Pick the matching profile in
   [references/target-profiles.md](references/target-profiles.md). It says how
   scouts drive and observe the target, what evidence must match, what each
   agent isolates, and how many can drive at once. Mixed targets get one
   profile per lens. Confirm the drive tool works (a browser, tmux, computer
   use, a simulator) before spawning scouts.
3. **Scout lenses.** Personas (for example admin, player, anonymous visitor),
   areas, or audit themes (security, accessibility, performance, API ergonomics,
   docs accuracy). Ask for the priority order.
4. **Codeblind or not.** For user-facing work, codeblind scouts judge only what
   a user would see. For audits, scouts read code.
5. **Merge authority.** By default every merge needs the user's approval.
6. **Round length.** Open-ended until the user ends it, or a target count.

## Roles

| Role              | Lifetime                  | Job                                                                                                                    |
| ----------------- | ------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Coordinator (you) | Whole round               | Decide, sequence, relay, talk to the user, run approved merges.                                                        |
| Setup/ops agent   | Whole round               | Start the environment, write the scout briefing, then handle restarts, pulls, and migrations after merges.             |
| Scout             | Whole round, one per lens | Explore independently, keep a private ranked backlog, return only the single top finding when asked.                   |
| Implementer       | One per finding           | File one issue, capture BEFORE evidence, fix in an isolated worktree, open a PR (never merge), capture AFTER evidence. |
| Reviewer          | One per PR, fresh         | Review only. Return a verdict and ranked findings with `file:line`.                                                    |
| Designer          | On demand                 | When the user wants options: 3 to 6 directions as mockups in the profile's format, with a recommendation.              |
| Triage            | On demand                 | For CI failures on main: classify flake vs. regression with evidence before anyone touches code.                       |

Prompt templates for every role are in
[references/prompt-templates.md](references/prompt-templates.md). Fill the
`{placeholders}`, drop `{variant}` lines that don't apply to the target, and
keep the remaining rules intact; they encode lessons from
real incidents.

### Setup/ops agent

Starts the shared environment and writes a briefing file for scouts. The shared
environment is whatever the profile says: a running server for a web app, or a
built binary or app bundle that each scout launches in its own isolated
instance for a TUI or GUI.

The briefing holds only what scouts need. For codeblind UI scouts that means
user-facing information only: for a web app, URLs, logins per persona, fixtures,
and seed data; for a TUI or GUI, the launch command, how to start an isolated
instance, sizes to test, and fixture files. Leaking file paths or code into a
codeblind briefing turns the scout into a code reviewer and you lose the user's
point of view.

Keep this agent alive. After every merge, send it to update the shared
environment so scouts test the current build: restart the server, or rebuild
the artifact and tell scouts to relaunch (see
[references/environment-hygiene.md](references/environment-hygiene.md)).

### Scouts

Scouts run in parallel and never coordinate with each other. Each one:

- explores through its lens and keeps a private ranked backlog file,
- returns only its single top finding, in the fixed finding format,
- waits for the coordinator to say "next" before returning another,
- re-verifies the finding against the latest build before reporting it,
  relaunching its instance first when the target is a built artifact.

One finding at a time keeps the user's decision queue short and lets the scout
re-rank as fixes land. A dump of twenty findings goes stale within an hour.

Finding format (title, where, observed vs. expected, why it hurts plus severity,
repro steps, evidence paths, remaining count) is defined in the scout template.

### Implementer

One fresh agent per finding, in its own git worktree and its own instance of the
profile's isolation unit (a port, a config dir, a tmux socket). Flow: file one
issue, capture BEFORE evidence under the profile's capture conditions, implement with one signed conventional commit, open a
PR, capture AFTER evidence in the same conditions, and look at its own evidence
before claiming the fix. It never merges. If the `work-github-issue` and
`create-github-issue` skills are installed, the implementer should follow them
for branch, commit, and PR conventions, with merge withheld.

### Reviewer

A fresh agent per PR, so it has no stake in the implementation. Give it specific
focus areas, not a generic "review this":

- the profile's reviewer focus (for example authorization and data exposure
  for a web app, terminal-state restoration and resize handling for a TUI,
  keyboard focus and HiDPI for a GUI),
- the edge cases the implementer named in its report,
- conflicts with other open PRs touching the same files,
- CI status,
- anything the user flagged when deciding the finding.

Ask for a verdict (approve, approve with nits, request changes) plus ranked
findings with `file:line`. Relay must-fix findings to the same implementer by
continuing it, not by starting a new one; it holds the branch context. For
security-sensitive changes, run a second adversarial reviewer told to try to
break it.

### Designer and triage

Spawn the designer only when the user asks for options or a finding has no
obvious fix. It renders 3 to 6 directions in the profile's mockup format (for
example HTML at desktop and mobile widths for web, text mockups at several
terminal sizes for a TUI), as images in each theme the target supports, with a
recommendation. The user picks,
then an implementer builds the chosen direction.

Spawn triage when CI fails on main. Nobody touches code until triage has
classified the failure with evidence: same SHA passing elsewhere, rerun results,
failure history.

## The Loop

For each finding:

1. **Report.** A scout returns its top finding.
2. **Decide.** Relay it to the user with the evidence files attached. Ask one
   question with 2 to 4 concrete options and your recommendation. Bundle a
   closely related second decision only when it would otherwise come up straight
   after.
3. **Implement.** Spawn an implementer with the decision. Respect the WIP limit
   below.
4. **Review.** Spawn a fresh reviewer when the PR is open.
5. **Rework.** Relay reviewer findings to the same implementer. Repeat review
   when the rework was substantive.
6. **Verify.** Have the implementer (or the scout that found it) re-verify on
   the PR build.
7. **Show.** Send the user like-for-like before/after evidence and a two-line
   summary. Ask for merge approval.
8. **Merge.** On approval, merge (below), then tell the ops agent to update the
   environment and tell other open PRs' agents that main moved.
9. **Next.** Ask the scout for its next finding.

User feedback on evidence is a new review finding. Relay it to the implementer.
If the user says it is non-blocking, don't hold unrelated merges for it.

### Merge

Fast-forward only, run by the coordinator, only after explicit approval from the
user in this conversation:

```bash
git fetch origin
git merge-base --is-ancestor origin/main <sha> && git push origin <sha>:refs/heads/main
```

If the ancestor check fails, send the implementer to rebase, then re-check CI
before asking again. Keep a running merged count and report it.

## Concurrency and WIP Limits

- At most about 2 fresh implementations in flight. Review and rework rounds
  don't count against the limit. Queue extra findings and tell the user they are
  queued.
- Ask scouts for the next finding when a slot frees, following the user's
  persona or area priority.
- Sequence PRs that touch the same files. Either wait for the first to merge or
  stack the second on it, then rebase and retarget when the base merges.
- Detect resource collisions early: duplicate migration numbers, the same port,
  the same config dir, the same fixture name. Decide who renumbers and tell both
  agents.
- **Driver contention.** Some drive methods have a single holder. Computer use
  on one desktop shares one screen, keyboard, and mouse, so two GUI scouts
  would click into each other's windows. Run such agents in parallel only when
  each has its own display, VM, or simulator. Otherwise hold a driver token
  yourself:
  - Any agent that needs the screen (scouts, implementer BEFORE and AFTER
    captures, setup and ops smoke checks, re-verification, adversarial runs)
    stops and reports "need the screen" instead of driving. You continue it
    with "your turn" when the token is free, and it returns the token with its
    report.
  - Give implementer captures priority over scout exploration, so a fix isn't
    held up by an open-ended scout turn. Time-box scout turns (for example "one
    finding or 15 minutes, whichever comes first").
  - Global settings in the capture conditions (OS theme, display scale,
    accessibility options such as Full Keyboard Access) belong to the token
    holder, who restores them before handing the token back.
  - Captures run one at a time, so the screen, not the WIP limit, sets the
    pace. Don't start more implementers than the screen can serve.
  - Agents that only read code, build, or run headless tools don't need the
    token.

## Shared Environment

A swarm of agents can break a shared environment faster than one person can.
Read [references/environment-hygiene.md](references/environment-hygiene.md)
before the first spawn, and paste the rules relevant to the target into every
implementer and scout prompt (the templates already carry the core ones). The short version:

- unique session and instance names per agent (browser sessions, tmux sockets,
  app profiles), never "close all" or kill-by-pattern,
- nobody stops or reseeds shared services without authorization,
- implementers get their own isolation unit from the profile: a server on a
  unique port from committed example env, an isolated config and data dir, a
  throwaway container for schema changes,
- clean up throwaway resources by name or PID you started, never with a prune,
- keep the shared environment on the latest main after each merge,
- watch for leaks caused by the swarm itself.

## Permissions and Authority

- Subagents should refuse approval relayed through the coordinator for
  destructive or outward actions (resets, force pushes, merges, deletes).
  Consent must come first-hand from the user. That refusal is correct; don't
  argue with it.
- When the user grants authority in their own words, run that single command
  yourself and record the grant (for example in memory) with its scope.
- Never work around a permission denial. Surface it with exact options: the user
  runs it with a `!` command, grants the authority, or adds a permission rule.
- If an agent made a mistake (an over-broad cleanup, a wrong push), tell the
  user plainly what happened and what you did about it.

## Escalate or Decide

Escalate to the user: product behavior, UX direction, trade-offs with visible
impact, security posture, and anything destructive.

Decide yourself when there is a clear best practice (naming, test placement, an
obvious accessibility fix) and say what you decided in the next update.

When the user states a durable preference ("greenfield, no legacy-compat shims",
"always dark and light screenshots"), record it to memory so you stop asking.

## Talking to the User

Assume the user may be remote and reading on a phone.

- Short status updates: what merged, what is in flight, what is queued, what
  needs them. Say plainly when nothing needs them.
- Send evidence files proactively, not paths.
- Keep the running merged count in each update.
- Never claim a result before the agent reports it.
- Batch independent decisions in one question call when sensible.
- If an answer is ambiguous or empty, ask again rather than guess.

## Pitfalls

- **Unseen evidence.** Implementers claim fixes without opening their own
  evidence. Require them to describe what the AFTER evidence shows.
- **Unlike comparisons.** Before and after captured under different conditions:
  theme, viewport, terminal size, colour depth, display scale, data state.
  Require like-for-like under the profile's capture conditions and reject
  evidence that isn't.
- **Stale shared server.** Scouts re-report fixed bugs. Update the environment
  after every merge and have scouts re-verify before reporting.
- **Stale binary.** For TUI and GUI targets, a scout's running instance keeps the
  old build after a rebuild. Scouts relaunch before re-verifying.
- **Broken terminal.** A TUI that crashes or is killed can leave the pane in raw
  mode or the alternate screen, corrupting later captures. Kill and recreate the
  tmux session rather than reusing it.
- **Focus theft.** A GUI dialog, permission prompt, or leftover window from one
  agent grabs focus while another drives. Close your windows when you hand back
  the driver token.
- **Stale stacks.** Stacked PRs go stale when the base is amended. Tell the
  stacked agent each time the base changes.
- **Automated checks are not the real thing.** An automated accessibility
  snapshot is not a screen-reader pass, and a tmux capture is not a real
  terminal emulator. List such gaps as manual steps (each profile has a
  manual-only list).
- **Reviewer vs. user.** A reviewer finding that contradicts an earlier user
  decision goes back to the user with the new information. Don't silently
  override the user.
- **Coordinator bloat.** Reading transcripts, diffs, or logs yourself. Ask an
  agent to summarize instead.
- **Swarm-caused failures.** Connection exhaustion, file-watcher reload storms,
  disk filling with worktrees. Suspect the swarm before the code.

## Wind-Down

When the user ends the round:

1. Tell scouts to stop sending findings and finalize their backlog files.
2. Land in-flight work that is close. Park the rest with a clear status.
3. Compile unsubmitted findings into a shareable doc.
4. Report open manual steps, known flakes, leftover test data, and environment
   state.

Use the wind-down template in
[references/prompt-templates.md](references/prompt-templates.md) and the report
outline in [references/wind-down-report.md](references/wind-down-report.md).

## Reference Implementation (Claude Code)

The skill is tool-agnostic. In Claude Code the pieces map to specific tools; see
[references/claude-code.md](references/claude-code.md).
