# Reference Implementation: Claude Code

The workflow is tool-agnostic. This is how each piece maps to Claude Code tools.
Other harnesses have equivalents; use the closest one.

| Need                          | Claude Code                               | Notes                                                                                                                                                       |
| ----------------------------- | ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Spawn a role                  | `Agent` tool                              | One call per agent. Spawn independent agents (scouts, setup) in the same message so they run concurrently.                                                  |
| Isolated implementer          | `Agent` with `isolation: "worktree"`      | Gives the agent its own git worktree. If a shared dev server watches files, make it ignore the worktrees directory.                                         |
| Continue an agent             | `SendMessage` with the agent's ID or name | Use for "next" to scouts, review relays to implementers, ops updates, and main-moved notices. A new `Agent` call starts fresh and loses the branch context. |
| Drive a web app               | `agent-browser` or `playwright-cli` skill | Named sessions per agent. Also drives Electron apps over CDP.                                                                                               |
| Drive a TUI                   | `Bash` with tmux                          | `tmux -L {session}` per agent; `send-keys` for input, `capture-pane -p` for evidence. The `run` skill has launch patterns for TUIs and CLIs.                |
| Drive a native GUI            | Computer-use MCP                          | One shared screen: only the agent holding the driver token drives. Load the `computer-use` skill first.                                                     |
| Drive a mobile app            | `Bash` with `xcrun simctl` or `adb`       | One named simulator or emulator per agent.                                                                                                                  |
| Ask the user                  | `AskUserQuestion`                         | One question with 2 to 4 options and a recommended choice; several independent questions can go in one call.                                                |
| Send evidence                 | `SendUserFile`                            | Send screenshots and mockups directly so a remote user sees them. Don't just paste paths.                                                                   |
| Record preferences and grants | Memory files                              | Save durable preferences ("no legacy shims") and explicit authority grants with their scope.                                                                |
| Run an approved merge         | `Bash` in the coordinator                 | The only command the coordinator runs itself.                                                                                                               |
| Shareable wind-down report    | Artifact or a document connector          | Publish so the user can pass it on.                                                                                                                         |

## Coordinator habits in Claude Code

- Agent results arrive as notifications. Don't predict or summarize a result
  before it arrives; say the agent is still running.
- Don't read agent transcripts or output files to "check". Ask the agent.
- Keep the WIP count, port ledger, driver-token holder, and merged count in your
  own messages so they survive context compaction.
- When a permission prompt is denied, tell the user the exact command and offer:
  run it with `!<command>`, grant authority in their own words, or add a
  permission rule (the `update-config` skill helps).
