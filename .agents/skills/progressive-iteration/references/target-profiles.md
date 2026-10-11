# Target Profiles

The loop is the same for every target. What changes is how scouts drive and
observe the target, what "like-for-like" evidence means, what each agent
isolates, and what the shared environment is. Pick one profile per target
before the first spawn. Mixed targets (a CLI with a TUI mode, a web app with an
Electron shell) use one profile per lens.

Fill template placeholders such as `{drive_method}`, `{capture_conditions}`,
`{isolation}`, and `{launch_cmd}` from the chosen profile. Profiles list the
capture dimensions; the setup agent proposes concrete values (sizes, themes,
the minimum supported size) in the briefing, and the coordinator confirms them.

Override `HOME` or `XDG_*` only in the environment of the target process,
never in an agent's own shell; git signing, credentials, and pushes depend on
the real ones. A target that itself uses git or SSH (a git client, a deploy
tool) also needs `GIT_CONFIG_GLOBAL` and similar pointed at temp files, and no
access to the agent's SSH agent or credential helper unless the user allows it.

## Contents

1. [Web app](#web-app)
2. [CLI](#cli)
3. [TUI](#tui)
4. [Desktop GUI (native)](#desktop-gui-native)
5. [Desktop GUI (Electron or webview)](#desktop-gui-electron-or-webview)
6. [Mobile](#mobile)
7. [Library, infra, docs](#library-infra-docs)

Every profile has the same fields:

| Field              | Question it answers                                                  |
| ------------------ | -------------------------------------------------------------------- |
| Drive              | How does a scout operate the target?                                 |
| Capture            | What evidence formats, captured how?                                 |
| Capture conditions | What must match between BEFORE and AFTER?                            |
| Isolation          | What does each agent get of its own?                                 |
| Parallelism        | How many agents can drive at once?                                   |
| Shared environment | What does ops keep current, and what does "update after merge" mean? |
| Briefing           | What goes in the scout briefing?                                     |
| Designer output    | What form do mockups take?                                           |
| Reviewer focus     | Default focus areas beyond the generic ones.                         |
| Adversarial        | Attack surface for the adversarial reviewer.                         |
| Manual-only        | Checks agents can't do, for the wind-down report.                    |

## Web app

- **Drive:** browser automation with a named session per agent.
- **Capture:** screenshots (PNG), page text or accessibility snapshot, console
  and network logs. Short recordings for timing or animation bugs.
- **Capture conditions:** theme (dark/light), viewport, persona or login, data
  state, browser.
- **Isolation:** a unique port per implementer, the committed example env
  (`.env.example`), a throwaway database container for schema changes, a unique
  browser session name.
- **Parallelism:** unlimited in practice; headless browsers don't contend.
- **Shared environment:** a running server on the latest main. After a merge:
  pull, install if lockfiles changed, apply additive migrations, restart if
  needed, smoke-check URLs.
- **Briefing:** URLs, logins per persona, seed data, what is safe to create, how
  to reset one's own state.
- **Designer output:** static HTML mockups with the project's real tokens,
  rendered to PNG in dark and light, desktop and mobile.
- **Reviewer focus:** authorization (can a lower-privileged user reach it?), data
  exposure in responses, logs, and client bundles.
- **Adversarial:** privilege escalation, IDOR, injection, malformed input, races,
  replay, error and timing leaks, bypassing the UI to hit the API.
- **Manual-only:** a real screen-reader pass, physical mobile devices, email
  deliverability.

## CLI

- **Drive:** run commands in a shell with fixed inputs; pipe stdin where needed.
- **Capture:** stdout, stderr, and exit code saved to text files, with the exact
  command line. Text is the evidence; render to an image only for the user.
- **Capture conditions:** command and arguments, working directory and fixtures,
  environment variables that change output (`NO_COLOR`, `TERM`, locale), TTY vs.
  piped, OS.
- **Isolation:** a temp working directory, an isolated config and data dir
  (`HOME` or `XDG_CONFIG_HOME`/`XDG_DATA_HOME`/`XDG_CACHE_HOME` pointed at a temp
  dir), a separate build output dir per worktree.
- **Parallelism:** unlimited, as long as nobody shares a config dir.
- **Shared environment:** a built binary from the latest main at a known path.
  After a merge: rebuild, then tell scouts the new build is ready.
- **Briefing:** the binary path, how to set up an isolated config dir, fixture
  directories, and which commands touch the network or real accounts.
- **Designer output:** text mockups of help output, errors, and progress, at a
  narrow and a wide terminal width.
- **Reviewer focus:** exit codes, stderr vs. stdout, piped (non-TTY) output,
  backwards compatibility of flags and output formats scripts depend on.
- **Adversarial:** malicious arguments and files, path traversal, unsafe
  shell-outs, symlink races, secrets in logs or errors.
- **Manual-only:** other shells and OSes, real terminal emulators.

## TUI

- **Drive:** a tmux session per agent on its own socket
  (`tmux -L {session} new-session -d -s {session} -x {cols} -y {rows} '{launch_cmd}'`),
  input with `send-keys`, output with `capture-pane`.
- **Capture:** `tmux capture-pane -p` (plain text) and `-p -e` (with ANSI
  styles) to files. Text captures diff cleanly; prefer them as the evidence of
  record. Render to PNG (for example with `freeze`, or `vhs`/`asciinema` + `agg`
  for recordings) only to show the user. Record a short cast for
  timing, focus, or animation bugs.
- **Capture conditions:** terminal size (cols x rows), `TERM`, colour depth
  (truecolor, 256, none, `NO_COLOR`), locale and Unicode width, key sequence
  sent, data state, and the terminal emulator if the image comes from a real
  one.
- **Isolation:** a unique tmux socket and session name, an isolated config and
  data dir as for a CLI, a separate build output dir.
- **Parallelism:** unlimited; tmux sessions on separate sockets don't contend.
- **Shared environment:** a built binary from the latest main. After a merge:
  rebuild, then tell scouts to relaunch. A running TUI keeps the old build.
- **Briefing:** the launch command, required terminal sizes, the tmux recipe
  above, key bindings a user would discover, fixture data, isolated config
  setup, and which actions touch the network or real accounts.
- **Designer output:** plain-text or ANSI mockups at two or three terminal sizes
  (for example 80x24, 120x40, and the minimum supported), rendered to PNG for the
  user.
- **Reviewer focus:** resize handling, terminal state restored on exit, crash,
  and `^C` (raw mode, alternate screen, cursor), signal handling, key-binding
  conflicts, no-colour and narrow-terminal fallbacks, wide characters.
- **Adversarial:** terminal escape-sequence injection from untrusted data
  (file names, remote content), malicious config and input files, path
  traversal, unsafe shell-outs.
- **Manual-only:** real terminal emulators (iTerm2, Ghostty, Windows Terminal,
  Linux consoles), real fonts and ligatures, screen readers in a terminal.

## Desktop GUI (native)

- **Drive:** computer use (screenshots plus mouse and keyboard), or the
  platform's UI automation (macOS Accessibility/AppleScript, XCUITest, Windows
  UI Automation, AT-SPI on Linux) where the project has it.
- **Capture:** window screenshots rather than full-screen, to avoid leaking
  other windows (on macOS `screencapture -l <window-id>`, or crop a computer-use
  screenshot to the window), accessibility tree dumps, app logs, short screen recordings for
  focus, animation, or timing bugs.
- **Capture conditions:** window size, display scale (1x/2x), OS theme
  (dark/light), OS version, locale, accessibility settings (larger text, reduced
  motion, increased contrast), data state.
- **Isolation:** an isolated config, data, and preferences dir (a temp `HOME`, a
  `--user-data-dir`-style flag, or a launch argument the app honours), a
  separate build output dir. Sandboxed macOS apps keep state under their bundle
  ID and ignore `HOME`, so isolation means a distinct bundle ID per agent build
  (or a data-dir launch argument added for testing). If neither exists, scouts
  share state; since they also share the screen, they run one at a time, and
  each resets the app's state to the briefing's baseline before handing back
  the token. Watch for single-instance locks: a second launch may just focus
  the first instance (`open -n` forces a new one on macOS).
- **Parallelism:** one driver per physical screen. Computer use shares one
  mouse, keyboard, and focus, so agents on the same desktop must take turns (see
  driver contention in SKILL.md). Run more in parallel only with separate
  displays or VMs (Xvfb on Linux, macOS or Windows VMs).
- **Shared environment:** a built app from the latest main at a known path.
  After a merge: build to a new versioned path (or have scouts quit first),
  since replacing a bundle under a running app breaks it, then tell scouts to
  relaunch from the new path. Each new unsigned build can trigger OS permission
  or keychain prompts; the ops agent clears them during its smoke check (holding
  the driver token) or reports them to the coordinator for the user.
- **Briefing:** the app path and launch command, how to start it with an
  isolated profile, window sizes to test, fixture documents, test accounts.
- **Designer output:** mockups as HTML approximations of the platform look, or
  as SwiftUI/toolkit previews rendered headlessly, at the briefing's window
  sizes, in dark and light, at 1x and 2x. Rendering doesn't need the driver
  token unless it opens windows on the shared screen.
- **Reviewer focus:** keyboard navigation and focus order, accessibility labels,
  HiDPI assets, platform differences, work on the main/UI thread, persistence of
  window state and preferences.
- **Adversarial:** malicious documents and config, custom URL-scheme and IPC
  handlers, file-open dialogs and path traversal, unsafe shell-outs, update and
  plugin loading.
- **Manual-only:** OS screen readers (VoiceOver, Narrator, Orca), real HiDPI
  and multi-monitor setups, other OS versions, signing, notarisation, and
  installer flows.

## Desktop GUI (Electron or webview)

Use the Web profile for the renderer, with these differences:

- **Drive:** browser automation over the Chrome DevTools Protocol (launch with a
  remote debugging port), or computer use for native menus, tray, and dialogs.
- **Capture conditions:** the Web set plus window size, display scale, and OS
  theme.
- **Isolation:** a unique debugging port and `--user-data-dir` per agent.
  Electron apps are often single-instance; a second launch without its own data
  dir focuses the first.
- **Parallelism:** CDP-driven agents run in parallel; computer-use driving
  follows the native rule.
- **Shared environment:** a built app, as for native.
- **Reviewer focus:** the Web set plus IPC exposed to the renderer
  (`contextIsolation`, preload APIs), native menus, auto-update.
- **Adversarial:** the Web set plus renderer-to-main IPC abuse, `shell.openExternal`
  with untrusted URLs, remote content loaded with Node access.

## Mobile

- **Drive:** a simulator or emulator per agent (`xcrun simctl`, `adb` with an
  AVD), with the platform's UI test tooling or computer use on the simulator
  window.
- **Capture:** simulator screenshots and recordings, device logs.
- **Capture conditions:** device model and size, OS version, dark/light,
  dynamic type size, locale, orientation.
- **Isolation:** one simulator or emulator per agent, by name. Erase only the
  ones you created.
- **Parallelism:** limited by machine resources; each simulator is heavy.
- **Shared environment:** a built app installed on each scout's simulator after
  every merge.
- **Manual-only:** physical devices, push notifications, store builds, real
  network conditions.

## Library, infra, docs

- **Drive:** read code and docs, run tests, examples, `plan`/dry-run commands,
  or a docs build.
- **Capture:** command output to text files, test results, rendered docs pages
  (use the Web profile for a docs site).
- **Capture conditions:** language or tool version, inputs, environment.
- **Isolation:** a worktree and its own build or virtual environment. For infra,
  never apply against shared or real accounts; plan only, or use a sandbox
  account the user named.
- **Parallelism:** unlimited for reads and tests; serialize anything that
  touches a shared state backend.
- **Shared environment:** usually none beyond the repo. Scouts pull the latest
  main before re-verifying.
- **Reviewer focus:** API compatibility and semver, docs matching behaviour,
  plan diffs for infra.
- **Adversarial:** input validation at public API boundaries, IAM and network
  exposure for infra, secrets in state or logs.
- **Manual-only:** applying infra to real accounts, publishing packages.
