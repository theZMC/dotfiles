# Shared-Environment Hygiene

Every rule here comes from a real incident in a multi-agent round. Paste the
relevant rules into scout and implementer prompts; agents don't read this file
on their own.

Target-specific isolation units, capture conditions, and parallelism limits are
in [target-profiles.md](target-profiles.md).

## Sessions and instances

- Give every agent a unique session name, for example `scout-admin`,
  `impl-342`: a browser session, a tmux socket and session
  (`tmux -L impl-342`), an app profile, or a simulator. Two agents sharing a
  session drive each other's pages or panes.
- Never use "close all" or kill-by-pattern. Close only what you opened, by name
  or by the PID you started. One agent's "close all", `tmux kill-server`, or
  `pkill <app>` ends every other agent's work.
- One desktop has one screen, keyboard, and mouse. Agents that drive a GUI with
  computer use take turns through the coordinator's driver token, and close
  their windows and dialogs before handing it back. Parallel GUI driving needs
  separate displays, VMs, or simulators.

## Shared services

- Nobody stops, restarts, reseeds, or resets the shared database or services
  without the coordinator's explicit instruction, and the coordinator needs the
  user's authorization for anything destructive.
- Only the ops agent updates the shared environment.

## Implementer isolation

- Servers: each implementer runs its own dev server on a unique port assigned by
  the coordinator. Keep a port ledger in your messages or a scratch file.
- Use the committed example env (`.env.example` or similar). Never copy the real
  `.env`; it may hold secrets and point at shared resources.
- Local apps: each agent points the target process's config, data, and cache
  dirs at a temp dir (`HOME`, `XDG_CONFIG_HOME`/`XDG_DATA_HOME`/`XDG_CACHE_HOME`,
  or the app's `--user-data-dir`/profile flag). Leave the agent's own shell
  alone; its git and credentials need the real ones. Two agents sharing a config file overwrite
  each other's settings and history, and an agent using the real one corrupts
  the user's.
- Single-instance apps: a second launch without its own data dir often just
  focuses the first instance, so the agent tests someone else's build. Give each
  instance its own data dir or dev bundle ID.
- Builds: each implementer builds inside its worktree, never into the shared
  artifact path the scouts launch from.
- For schema changes, use a throwaway database container with a name tied to the
  finding, for example `{project}-impl-342-db`.

## Cleanup

- Remove throwaway containers, volumes, networks, tmux sessions, simulators,
  and temp config dirs by name. Stop app processes by the PID you started.
- Never run `docker system prune`, `docker volume prune`, or similar. A prune
  deletes other agents' resources and possibly the shared database volume.
- Remove worktrees with `git worktree remove <path>`, not `rm -rf` on a parent
  directory.

## Keeping the shared environment current

After each merge, the ops agent:

1. pulls the base branch,
2. installs dependencies if lockfiles changed,
3. for a shared server: applies migrations only if they are additive (otherwise
   stops and reports), and restarts if native dependencies or server config
   changed,
4. for a shared artifact: rebuilds the binary or app bundle at the briefing's
   path, and the coordinator tells scouts to relaunch,
5. smoke-checks the entry points in the briefing.

Scouts testing a stale build re-report fixed bugs and waste a user decision. A
running TUI or GUI instance keeps the old build until it is relaunched.

## Swarm-caused leaks

The swarm itself can cause failures that look like product bugs. Suspect it
first when something degrades over the round.

- **File-watcher reload storms.** Worktrees placed inside the main checkout
  trigger the main dev server's file watcher on every checkout, install, or
  build. In one round each HMR reload leaked database connections until the
  server exhausted its pool. The fix was an ignore pattern for the worktrees
  directory in the watcher config. Prefer worktrees outside the repo, or add the
  ignore early.
- **Port and container collisions.** Two agents picking the same port or name.
- **Disk.** Many worktrees, each with its own dependency install and build
  output.
- **Rate limits.** Many agents calling the same API (GitHub, a test SMTP server)
  at once.
- **Orphans.** tmux sessions, app processes, and simulators left running by
  agents that finished or crashed. They hold ports, locks, and memory.
- **Focus theft.** A leftover window, crash dialog, or OS permission or keychain
  prompt from one agent takes focus while another drives the screen.
- **Shared state files.** Two instances writing the same config, history, or
  cache file, or an agent writing to the user's real one.

## Collisions between PRs

- Migrations: check open PRs for the next number before creating one. On a
  collision, the later PR renumbers; tell both agents.
- Same files: sequence the PRs, or stack the second on the first and retarget
  after the first merges.
- Shared fixtures or seed data: changes go in one PR at a time.
