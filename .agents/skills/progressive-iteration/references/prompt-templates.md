# Prompt Templates

Fill every `{placeholder}`. Values for the target-specific placeholders come from
the chosen profile in [target-profiles.md](target-profiles.md). Lines in the form
`{Variant: ...}` apply only to that kind of target; drop the ones that don't
fit (for example the schema-container rule for a TUI with no database). Keep
every other rule; each line exists because something went wrong without it.

Common placeholders:

| Placeholder            | Meaning                                                                                                           |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `{repo}`               | `owner/repo`                                                                                                      |
| `{repo_path}`          | Absolute path of the main checkout                                                                                |
| `{base}`               | Base branch, usually `main`                                                                                       |
| `{briefing_path}`      | Scout briefing written by the setup agent                                                                         |
| `{target}`             | What is being explored, for example "the admin web app" or "the `gt` TUI"                                         |
| `{scope}`              | Paths or areas an audit scout covers                                                                              |
| `{constraints}`        | Durable user preferences that bind implementers                                                                   |
| `{slug}`               | Short name for one finding, for example `impl-342-empty-state`                                                    |
| `{container_prefix}`   | Prefix for throwaway containers, usually the project name                                                         |
| `{problem}`            | The design problem, in one or two lines                                                                           |
| `{sizes}`              | The concrete sizes to render or test, taken from the briefing                                                     |
| `{evidence_dir}`       | Where screenshots, logs, and outputs go, for example `{repo_path}/.evidence` (gitignored)                         |
| `{persona}` / `{lens}` | Scout persona or audit theme                                                                                      |
| `{backlog_path}`       | The scout's private backlog file                                                                                  |
| `{target_type}`        | The profile name: web, CLI, TUI, desktop GUI, Electron, mobile, library/infra/docs                                |
| `{drive_method}`       | How this agent drives the target, from the profile                                                                |
| `{launch_cmd}`         | How to start an instance of the target from the current build                                                     |
| `{capture_conditions}` | The profile's like-for-like dimensions with values; the setup agent proposes them in the briefing and you confirm |
| `{isolation}`          | This agent's isolation unit: port, config/data dir, tmux socket, simulator, user-data dir                         |
| `{session}`            | A unique session or instance name for this agent (browser, tmux, app profile)                                     |
| `{port}`               | A port reserved for this agent (web and Electron)                                                                 |
| `{finding}`            | The scout's finding, pasted verbatim                                                                              |
| `{decision}`           | The user's choice, in their words where possible                                                                  |

## Contents

1. [Setup/ops agent](#1-setupops-agent)
2. [Scout](#2-scout)
3. [Implementer](#3-implementer)
4. [Reviewer](#4-reviewer)
5. [Adversarial reviewer](#5-adversarial-reviewer)
6. [Follow-up relay to the implementer](#6-follow-up-relay-to-the-implementer)
7. [Main moved notice](#7-main-moved-notice)
8. [Ops update after merge](#8-ops-update-after-merge)
9. [Designer](#9-designer)
10. [CI triage](#10-ci-triage)
11. [Wind-down](#11-wind-down)

## 1. Setup/ops agent

```text
You are the setup and ops agent for {repo} at {repo_path}. You will stay alive
for the whole session; I will send you follow-up work after merges.

Task now:
1. Get the shared environment running from {base}. Use the project's
   documented commands (README, mise/make/npm tasks) before inventing your own.
   {Shared server: dependencies, services, database, seed data, and the running
   app.}
   {Shared artifact (CLI, TUI, desktop, mobile): build the binary or app bundle
   to a known path, prepare fixtures, and work out how to start an isolated
   instance (its own config and data dir, tmux socket, user-data dir, or
   simulator).}
2. Confirm it works end to end the way a user would reach it, using
   {drive_method}.
3. Write a scout briefing to {briefing_path}.

The briefing is for {codeblind|code-reading} scouts. Include only what they
need:
- entry points (URLs, endpoints, or the launch command and artifact path),
- how to start an isolated instance, and the sizes to test (viewports,
  terminal cols x rows, window sizes),
- per persona ({personas}): logins or credentials, or the fixture data that
  makes the persona (for example a large repo for a power user),
- default capture conditions: concrete values for {capture_conditions}
  (for example 80x24 and 120x40, truecolor; or 1280x800 window, 2x, dark and
  light), including the minimum supported size,
- which actions touch the network, real accounts, or anything outside the
  scout's isolated instance,
- fixtures and seed data a scout can rely on, and what is safe to create,
- how to reset their own state without touching anyone else's.
{For codeblind scouts: do NOT include source paths, code, stack details, or
known bugs. They must judge only what a user sees. The artifact path and launch
command are fine; a user has those too.}

Rules:
- Do not copy secrets into the briefing beyond the test logins it needs.
- Record which ports, container names, config dirs, and session names the
  shared environment uses so implementers can avoid them.
- Do not stop, reseed, or reset shared services later without my explicit
  instruction.

Return: environment status, entry points or artifact path and its SHA, the
briefing path, reserved ports and resource names, and anything that needed a
workaround.
```

## 2. Scout

```text
You are a scout exploring {target} ({target_type}) as {persona|lens}. You work
alone; other scouts cover other lenses. Read {briefing_path} first.

{Codeblind variant: Behave like a real {persona}. Judge only from what you can
see: screenshots, screen or pane text, command output. Do not read the source
code.}
{Audit variant: Read the code and docs under {scope}. Focus on {lens}.}

Drive: {drive_method}. Start your instance with {launch_cmd} using {isolation}.
Session: use the name "{session}" for any browser, tmux, or app session. Never
close sessions you did not open; never use "close all" or kill-by-pattern.
{Driver token variant: You share one screen with other agents. Drive only
between my "your turn" and your report. Before reporting, close any windows or
dialogs you opened so the next agent starts clean.}
Evidence: save files to {evidence_dir}/{persona}/ with descriptive names, and
note the capture conditions ({capture_conditions}) with each one.

Protocol, one finding at a time:
1. Explore and keep a private ranked backlog at {backlog_path}. Rank by user
   impact, then by frequency, then by ease of repro.
2. Return ONLY your single top finding, then stop and wait.
3. When I say "next", relaunch your instance from the current build if the
   target is a built artifact, re-rank, re-verify the top item (it may already
   be fixed), and return it.
4. If I say an item is fixed or rejected, mark it in the backlog and move on.
5. Don't fix anything. Don't file issues. Don't touch shared services.
6. When you stop, close only what you started: your sessions, processes, and
   windows. For a TUI, kill your tmux session rather than leave a broken pane.

Finding format:

### {short title}
- **Where:** {URL / command / screen or view / key sequence / file}
- **Observed:** {what happens}
- **Expected:** {what should happen}
- **Why it hurts:** {impact on this persona}. Severity: {blocker|major|minor|polish}
- **Repro:**
  1. ...
- **Evidence:** {paths to screenshots, pane captures, recordings, logs}
- **Conditions:** {capture conditions the evidence was taken under}
- **Verified on:** {build / commit / time}
- **Backlog remaining:** {count}
```

## 3. Implementer

```text
You implement one finding for {repo}. Work in an isolated git worktree off
{base}; never edit {repo_path} directly.

Finding (from a scout):
{finding}

User decision: {decision}
Constraints the user set: {constraints, e.g. "greenfield, no legacy shims"}

Flow:
1. File ONE issue describing the problem and acceptance criteria{ using the
   create-github-issue skill if available}.
2. Capture BEFORE evidence of the problem in {evidence_dir}/{slug}/before/
   using {drive_method}. Record the exact conditions: {capture_conditions}.
3. Implement the fix. Add or update tests that would have caught it. Keep one
   signed conventional commit on the branch; amend for later changes and push
   with --force-with-lease.
4. Run the project's checks that cover your change.
5. Open a PR that closes the issue. Do NOT merge.
6. Capture AFTER evidence in the SAME conditions as BEFORE into
   {evidence_dir}/{slug}/after/.
7. Open and look at your own evidence. Describe what each AFTER file shows.
   If it does not show the fix, you are not done.

Environment rules:
- Run your own instance with {isolation}. {Web: your own dev server on port
  {port} using the committed example env (for example .env.example); never copy
  a secrets .env.} {TUI/CLI/GUI: point HOME or XDG_* dirs (or the app's
  user-data flag) at a temp dir for the target process only, so it never reads
  or writes the real config. Don't change them in your own shell: git signing,
  credentials, and pushes need the real ones. Build into your worktree, not the
  shared artifact path.}
- For schema changes, use a throwaway container named {container_prefix}-{slug}
  and remove it by name when done. Never prune.
- Use the session name "{session}". Never close sessions or kill processes you
  did not start.
- {Driver token variant: You share one screen with other agents. When you
  reach a capture step, stop and report "need the screen" with what you will
  capture. I'll continue you with "your turn". Capture, restore any global
  settings you changed, close your windows, then report.}
- Do not stop, reseed, migrate, or rebuild the shared environment.
- If you need a migration number, check open PRs for collisions and tell me
  the number you chose.

Return: issue URL, PR URL, branch, commit SHA, checks run and results, BEFORE
and AFTER evidence paths with one line each on what they show, edge cases you
considered or left open, and files touched (so I can spot overlap).
```

## 4. Reviewer

```text
You are an independent reviewer for {pr_url} in {repo}. Review only: do not
edit, commit, push, or merge. You have no stake in this implementation.

Context:
- Finding it addresses: {finding_title}
- User decision: {decision}
- Implementer's stated edge cases: {edge_cases}
- Other open PRs touching nearby files: {other_prs}

Focus on:
1. {focus_1 from the profile's reviewer focus, e.g. authorization for web,
   terminal state restored on crash and ^C for a TUI}
2. {focus_2, e.g. data exposure for web, resize and narrow-terminal handling for
   a TUI, keyboard focus order and HiDPI for a GUI}
3. The implementer's edge cases: are they handled and tested?
4. Merge conflicts or semantic clashes with {other_prs}.
5. CI status on the PR head.
6. Does the change actually satisfy the user decision above?

Return:
- **Verdict:** approve | approve with nits | request changes
- **Findings**, ranked, each with severity (must-fix / should-fix / nit),
  `file:line`, the problem, and a suggested fix.
- Anything that contradicts the user decision, called out separately.
```

## 5. Adversarial reviewer

Use in addition to the reviewer for auth, payments, file handling, input
parsing, secrets, IPC or URL-scheme handlers, rendering untrusted data in a
terminal, or anything exposed to untrusted users or files.

```text
You are an adversarial reviewer for {pr_url}. Your job is to break it. Assume
the author missed something. Review only; do not push or merge.

Attack surface: {surface, e.g. the new answer-check endpoint, or the file
preview pane}
Try at least the profile's adversarial list: {attacks, e.g. for web: privilege
escalation, IDOR, injection, oversized or malformed input, races, replay, leaks
in errors and timing, bypassing the UI to hit the API; for a TUI or desktop app:
malicious files and config, terminal escape sequences in untrusted data, path
traversal, IPC and URL-scheme abuse, unsafe shell-outs}.

You may run the PR locally with {isolation} and throwaway data. Do not touch
the shared environment.

Return each successful or plausible attack with repro steps, `file:line`, and
severity, then a one-line overall verdict.
```

## 6. Follow-up relay to the implementer

Send to the SAME implementer agent (continue it), not a new one.

```text
Review results for your PR {pr_url}. Address the must-fix and should-fix items;
use judgment on nits and tell me which you skipped and why.

{ranked findings, pasted verbatim}

{Optional: User feedback on your AFTER evidence: "{quote}". Treat as must-fix
| non-blocking.}

Amend your single commit, push with --force-with-lease, re-run the relevant
checks, and recapture AFTER evidence in the same conditions if anything visible
changed. Look at the new evidence before reporting.

Return: what changed per finding, the new SHA, checks, and new evidence paths.
```

## 7. Main moved notice

```text
main moved to {sha} ({merged_pr_title}). It touched {files_or_areas}. Rebase
your branch onto origin/main, resolve conflicts, re-run your checks, and push
with --force-with-lease. {If stacked: retarget your PR to main.} Report the new
SHA and any conflicts you had to resolve.
```

## 8. Ops update after merge

Shared server variant:

```text
main moved to {sha}. Update the shared environment so scouts test the current
build:
1. Pull {base} in {repo_path}.
2. Install dependencies if lockfiles changed. Restart the server if native
   dependencies or config changed.
3. Apply new migrations only if they are additive. If any migration is
   destructive or fails, stop and report; do not reseed or reset.
4. Smoke-check the entry points in {briefing_path}.
Return: new SHA running, what you ran, and anything that needs my decision.
```

Shared artifact variant (CLI, TUI, desktop, mobile):

```text
main moved to {sha}. Rebuild the shared artifact so scouts test the current
build:
1. Pull {base} in {repo_path}.
2. Install dependencies if lockfiles changed, then rebuild to the artifact path
   in {briefing_path}. {Mobile: reinstall on each scout's simulator by name.}
3. Smoke-check: launch one isolated instance with {launch_cmd}, confirm it
   starts and reports {sha} if it can, then close it.
4. Do not kill or restart scouts' running instances; I will tell them to
   relaunch.
Return: new SHA built, artifact path, what you ran, and anything that needs my
decision.
```

After the artifact variant, tell each scout: "New build at {sha}. Relaunch your
instance before re-verifying anything."

## 9. Designer

```text
You are a designer exploring options for: {problem}. The user wants to choose
a direction before anything is built.

Context: {finding and constraints}. Target type: {target_type}. Existing design
tokens, styles, or theme: {paths or "inspect the app"}.

Produce {3-6} distinct directions, not variations of one idea. For each:
- a mockup in the profile's format, using the project's real tokens or theme
  where possible: {web: static HTML | TUI: plain-text or ANSI mockups |
  desktop: native-toolkit terms or an HTML approximation of the platform look},
- rendered PNGs at {sizes, e.g. desktop and mobile widths | 80x24 and 120x40 |
  the target window sizes at 1x and 2x}, in each theme the target supports,
  saved to {evidence_dir}/design/{slug}/,
- two lines on the idea and its trade-off.

End with a recommendation and why. Do not modify the repo.
Return: the option list with PNG paths and your recommendation.
```

## 10. CI triage

```text
CI failed on {base} at {sha}: {workflow / job / test}. Classify it as flake or
regression before anyone changes code. Do not push fixes.

Gather evidence:
- Does the same SHA pass elsewhere (other runs, other jobs, locally)?
- Rerun the failed job once if allowed and record the result.
- Failure history of this test over recent runs.
- Which recent merges touched the failing area.

Return: verdict (flake | regression | infra), confidence, the evidence, the
likely culprit commit if a regression, and a suggested next step.
```

## 11. Wind-down

To each scout:

```text
We're ending the round. Don't send more findings. Finalize {backlog_path}:
mark items fixed (with PR links), rejected (with the reason I gave), or still
open, in ranked order with full finding format for open items. Close only the
sessions, processes, and windows you opened. Return the path and the open count.
```

To the compiler agent:

```text
Compile the round into a shareable report at {report_path} following the
outline in references/wind-down-report.md. Inputs: scout backlogs
{backlog_paths}, merged PRs {pr_list}, issues filed {issue_list}, open PRs
{open_prs}, environment notes {ops_notes}. Don't invent data; mark gaps.
Return the path and a five-line summary.
```
