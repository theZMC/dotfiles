---
name: create-mise-tasks
description: >
  Creates and manages mise file tasks and ensures required tools are declared in
  mise config. Use when the user asks to create, add, update, or refactor mise
  tasks, mentions `.mise/tasks`, asks about mise task structure or conventions,
  wants to automate project scripts through mise, or needs to declare
  mise-managed tools for their tasks. Also trigger when the user references
  "mise run", task dependencies, or task caching with sources/outputs.
metadata:
  author: Zach Callahan
  version: "1.1"
---

# Create Mise Tasks

## When to use this skill

Use this skill when the user asks to create, update, refactor, or standardize
[mise tasks](https://mise.jdx.dev/tasks/).

---

## Rules

### 1. Always use file tasks

- Every task must be a [file task](https://mise.jdx.dev/tasks/file-tasks.html).
- Do not create inline tasks in `mise.toml`.

### 2. Task property comment format

Use `# [MISE]` property comments at the top of each task file. The plain form
`#MISE key=value` is also valid, but prefer `# [MISE]` by default. Do not invent
other comment syntaxes.

```sh
#!/usr/bin/env bash
# [MISE] description="Build all packages"
# [MISE] depends=["lint", "test"]
# [MISE] sources=["src/**/*.ts", "package.json"]
# [MISE] outputs=["dist/**"]
# [MISE] env={NODE_ENV = "production"}
set -euo pipefail
```

**Available task properties:**

| Property       | Purpose                                               | Example                                       |
| -------------- | ----------------------------------------------------- | --------------------------------------------- |
| `description`  | Short human-readable summary                          | `description="Run unit tests"`                |
| `alias`        | Short name alternative(s)                             | `alias="b"` or `alias=["b", "build-all"]`     |
| `depends`      | Tasks that must run before this task                  | `depends=["build"]`                           |
| `depends_post` | Tasks that run after this task completes              | `depends_post=["notify"]`                     |
| `wait_for`     | Wait for these tasks if running, but don't start them | `wait_for=["render"]`                         |
| `env`          | Environment variables scoped to this task             | `env={DEBUG = "1"}`                           |
| `tools`        | Tool versions scoped to this task                     | `tools={rust = "1.50.0"}`                     |
| `dir`          | Working directory                                     | `dir="{{cwd}}"` or `dir="{{config_root}}/fe"` |
| `sources`      | Glob patterns; task is skipped if unchanged           | `sources=["src/**/*.rs"]`                     |
| `outputs`      | Expected output paths (paired with `sources`)         | `outputs=["target/release/mybin"]`            |
| `hide`         | Hide from `mise tasks` listing                        | `hide=true`                                   |
| `raw`          | Attach directly to terminal stdin/stdout/stderr       | `raw=true`                                    |
| `quiet`        | Suppress mise's own output for this task              | `quiet=true`                                  |
| `silent`       | Suppress all output (or `"stdout"` / `"stderr"`)      | `silent=true`                                 |
| `confirm`      | Prompt user for confirmation before running           | `confirm="Are you sure?"`                     |
| `shell`        | Override the shell used (toml-tasks only)             | `shell="zsh"`                                 |
| `usage`        | Advanced arg/flag spec (toml-tasks only)              | See mise docs on task arguments               |
| `redactions`   | Env vars to redact from output (experimental)         | `redactions=["API_KEY"]`                      |

**Notes on key properties:**

- `depends` supports passing args and env vars to dependencies:
  `depends=["NODE_ENV=test setup"]` or the structured form
  `depends=[{task = "build", args = ["--release"], env = {RUSTFLAGS = "-C opt-level=3"}}]`.
- `depends_post` runs tasks _after_ the current task (e.g., cleanup or
  notification steps) and supports the same syntax as `depends`.
- `wait_for` is an optional/soft dependency — it waits for a task if it's
  already running but won't start it otherwise.
- `outputs` defaults to `{auto = true}` when `sources` is defined, which tracks
  freshness automatically via an internal hash file.
- `tools` installs and activates tool versions for this task only (not passed to
  dependencies).

### 2.1 Task argument conventions (`[USAGE]`)

- Prefer `# [USAGE]` definitions for task inputs over ad-hoc positional parsing.
- Prefer named flags (for example `--version <version>`) over positional args for
  CI-facing tasks and workflows.
- Use positional args only for very simple local tasks with 1 required input.
- In scripts, read parsed values from `usage_*` variables (for example
  `usage_version`) and fail with clear messages when missing.
- Prefer invoking tasks as `mise run task --flag value` (no extra `--` separator)
  unless a specific mise behavior requires it.

Example:

```sh
#!/usr/bin/env bash
# [USAGE] flag "--version <version>" help="Release version"
set -euo pipefail

version="${usage_version?missing --version}"
```

### 3. Configuration locations

| Scope   | Location        |
| ------- | --------------- |
| Project | `.mise/`        |
| User    | `.config/mise/` |

Do not use alternate locations unless the user explicitly requires it.

### 4. Task file layout and namespacing

```text
.mise/
  tasks/
    build               # → mise run build
    test                # → mise run test
    lint/
      js                # → mise run lint:js
      python            # → mise run lint:python
```

- Nested directories create namespaced tasks (directory separators become `:`).
- Task files must be executable (`chmod +x`).
- Always use `#!/usr/bin/env <interpreter>` shebangs.
- For bash tasks, always include `set -euo pipefail` after the properties.
- **Interpreter choice:** default to bash. Use `python3` when the task needs
  complex data manipulation, JSON processing, or API calls. Use `node` when the
  task is tightly coupled to a JS/TS toolchain.

### 5. Dependencies

- `depends` references other task names: `depends=["build"]`.
- Namespaced dependencies use `:` syntax: `depends=["lint:js"]`.
- Use `depends_post` for tasks that should run after the current task (e.g.,
  cleanup, notifications).
- Use `wait_for` when a task should wait for another if it's already running,
  but shouldn't start it on its own.
- Mise detects circular dependencies and will error. If task A depends on B, do
  not also make B depend on A (directly or transitively).

### 6. Tools must be declared in mise config

Any tool a task uses must be declared in the relevant mise config (`.mise/config.toml`
preferred in this environment; otherwise `mise.toml` / `.mise.toml` if that is what
the project already uses). Before assuming a tool is unavailable, check these mise
backends:

| Backend | Example                        | Use for                       |
| ------- | ------------------------------ | ----------------------------- |
| core    | `node = "22"`                  | Node, Python, Ruby, Go, Java… |
| asdf    | `[plugins.tool]`               | Anything with an asdf plugin  |
| ubi     | `"ubi:owner/repo" = "latest"`  | GitHub release binaries       |
| cargo   | `"cargo:ripgrep" = "latest"`   | Rust crates with binaries     |
| npm     | `"npm:prettier" = "3"`         | npm packages with CLIs        |
| pipx    | `"pipx:black" = "latest"`      | Python CLI tools              |
| go      | `"go:pkg/path" = "latest"`     | Go modules with binaries      |
| aqua    | `"aqua:owner/repo" = "latest"` | aqua registry tools           |
| vfox    | `"vfox:plugin" = "latest"`     | vfox ecosystem tools          |

Pin versions explicitly when practical (e.g., `node = "22.1.0"` over
`node = "latest"`).

---

## Workflow checklist

When creating or updating tasks, follow this sequence:

1. **Scope** — project (`.mise/`) or user (`.config/mise/`)?
2. **Tools** — identify every tool the task needs; add declarations to mise
   config using the backends table above.
3. **Create task file** — place in the correct directory, add properties,
   shebang, and `set -euo pipefail` (for bash). Set executable bit.
4. **Add caching** — if the task has identifiable source files and outputs, add
   `sources` and `outputs` properties so mise can skip unchanged work.
5. **Validate** — confirm file placement, executable permission, tool
   declarations, and that dependency targets exist.

---

## Response format

After completing the task, report:

1. Task file(s) created or updated (with paths).
2. Mise config file(s) created or updated.
3. Tools added to mise config (with backend used).
4. Whether `sources`/`outputs` caching was applied.
5. Any tool that could not be sourced via mise, with backends checked.
