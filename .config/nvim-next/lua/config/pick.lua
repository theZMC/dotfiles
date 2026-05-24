local M = {}

local function get_pick()
  local ok, pick = pcall(require, "mini.pick")

  if ok then return pick end
end

local function get_extra()
  local ok, extra = pcall(require, "mini.extra")

  if ok then return extra end
end

local function show_with_icons(bufnr, items, query)
  local pick = get_pick()

  if not pick then return end

  pick.default_show(bufnr, items, query, { show_icons = true })
end

local function ensure_rg()
  if vim.fn.executable "rg" == 1 then return true end

  vim.notify("ripgrep is required for mini.pick file search and live grep", vim.log.levels.ERROR)
  return false
end

local function files_command(hidden)
  local command = {
    "rg",
    "--files",
    "--color=never",
    "--follow",
  }

  if hidden then table.insert(command, "--hidden") end

  return command
end

local function grep_command(pattern, hidden)
  local command = {
    "rg",
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
    "--follow",
  }

  if hidden then table.insert(command, "--hidden") end

  vim.list_extend(command, {
    "--field-match-separator",
    "\\x00",
    "--",
    pattern,
  })

  return command
end

local function grep_postprocess(lines)
  local items = {}

  for _, line in ipairs(lines) do
    if line ~= "" then
      local parts = vim.split(line, "\0", { plain = true })
      local path = parts[1]
      local lnum = tonumber(parts[2])
      local col = tonumber(parts[3])
      local text = table.concat(vim.list_slice(parts, 4), "\0")

      if path and lnum and col then
        table.insert(items, {
          path = path,
          lnum = lnum,
          col = col,
          text = ("%s:%d:%d: %s"):format(path, lnum, col, text),
        })
      end
    end
  end

  return items
end

function M.find_files(opts)
  local pick = get_pick()

  if not pick then return end
  if not ensure_rg() then return end

  local hidden = opts and opts.hidden or false
  local name = hidden and "Files (rg hidden, follow)" or "Files (rg follow)"

  return pick.builtin.cli({ command = files_command(hidden) }, {
    source = {
      name = name,
      show = show_with_icons,
    },
  })
end

function M.live_grep(opts)
  local pick = get_pick()

  if not pick then return end
  if not ensure_rg() then return end

  local hidden = opts and opts.hidden or false
  local name = hidden and "Grep Live (rg hidden, follow)" or "Grep Live (rg follow)"
  local sys = { kill = function() end }

  return pick.start {
    source = {
      items = {},
      name = name,
      show = show_with_icons,
      match = function(_, _, query)
        sys:kill()

        local pattern = table.concat(query)

        if pattern == "" then
          sys = { kill = function() end }
          return pick.set_picker_items({}, { do_match = false })
        end

        sys = pick.set_picker_items_from_cli(grep_command(pattern, hidden), {
          postprocess = grep_postprocess,
          set_items_opts = {
            do_match = false,
            querytick = pick.get_querytick(),
          },
        })
      end,
    },
  }
end

function M.diagnostics(scope)
  local extra = get_extra()

  if not extra then return end

  return extra.pickers.diagnostic {
    scope = scope == "current" and "current" or "all",
  }
end

function M.lsp(scope)
  local extra = get_extra()

  if not extra then return end

  return extra.pickers.lsp { scope = scope }
end

return M
