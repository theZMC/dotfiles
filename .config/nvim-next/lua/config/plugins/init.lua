require "config.plugins.pack"
require "config.plugins.treesitter"
require "config.plugins.conform"

local function setup_colorscheme()
  local ok, one_monokai = pcall(require, "one_monokai")

  if not ok then
    pcall(vim.cmd.colorscheme, "habamax")
    return
  end

  one_monokai.setup {
    transparent = true,
    italics = true,
  }

  pcall(vim.cmd.colorscheme, "one_monokai")
end

local function setup_copilot()
  local ok, copilot = pcall(require, "copilot")

  if not ok then return end

  copilot.setup {
    panel = { enabled = false },
    suggestion = {
      auto_trigger = true,
      hide_during_completion = true,
    },
    filetypes = {
      markdown = true,
      yaml = true,
    },
  }
end

local function setup_copilot_chat()
  local ok, chat = pcall(require, "CopilotChat")

  if not ok then return end

  chat.setup {
    window = {
      layout = "float",
    },
  }
end

local function setup_render_markdown()
  local ok, render_markdown = pcall(require, "render-markdown")

  if not ok then return end

  render_markdown.setup {
    code = {
      border = "thick",
    },
  }
end

local function setup_mini_tabline()
  local ok, mini_tabline = pcall(require, "mini.tabline")

  if not ok then return end

  mini_tabline.setup {
    show_tabs = true,
    show_devicons = true,
  }
end

local function setup_mini_clue()
  local ok, miniclue = pcall(require, "mini.clue")

  if not ok then return end

  miniclue.setup {
    triggers = {
      { mode = { "n", "x" }, keys = "<Leader>" },
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },
      { mode = "i", keys = "<C-x>" },
      { mode = { "n", "x" }, keys = "g" },
      { mode = { "n", "x" }, keys = "'" },
      { mode = { "n", "x" }, keys = "`" },
      { mode = { "n", "x" }, keys = '"' },
      { mode = { "i", "c" }, keys = "<C-r>" },
      { mode = "n", keys = "<C-w>" },
      { mode = { "n", "x" }, keys = "z" },
    },
    clues = {
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.windows {
        submode_move = true,
        submode_navigate = true,
        submode_resize = true,
      },
      miniclue.gen_clues.z(),
      { mode = "n", keys = "<Leader>a", desc = "󰚩 AI" },
      { mode = "n", keys = "<Leader>b", desc = "󰈔 Buffers" },
      { mode = "n", keys = "<Leader>c", desc = "󰅖 Close" },
      { mode = "n", keys = "<Leader>e", desc = "󰙅 Explorer" },
      { mode = "n", keys = "<Leader>f", desc = "󰍉 Find" },
      { mode = "n", keys = "<Leader>g", desc = "󰊢 Git" },
      { mode = { "n", "x" }, keys = "<Leader>l", desc = "󰒋 LSP" },
      { mode = "n", keys = "<Leader>o", desc = "󰙅 Open Explorer" },
      { mode = "n", keys = "<Leader>q", desc = "󰗼 Quit" },
      { mode = "n", keys = "<Leader>t", desc = " Terminal" },
      { mode = "n", keys = "<Leader>u", desc = "󰨚 Toggles" },
    },
    window = {
      delay = 500,
      config = {
        border = "rounded",
        width = "auto",
      },
    },
  }
end

local function setup_mini_pick()
  local ok, mini_pick = pcall(require, "mini.pick")

  if not ok then return end

  local style_group = vim.api.nvim_create_augroup("UserMiniPickStyle", { clear = true })
  local uv = vim.uv or vim.loop
  local footer_timer

  local function set_transparent_text()
    for _, group in ipairs { "MiniPickBorderText", "MiniPickPrompt", "MiniPickPromptCaret", "MiniPickPromptPrefix" } do
      vim.cmd.highlight(group .. " guibg=NONE ctermbg=NONE")
    end
  end

  local function trim(text) return text:gsub("^%s+", ""):gsub("%s+$", "") end

  local function fit_to_width(text, width)
    local text_width = vim.fn.strchars(text)

    if text_width <= width then return text end
    if width <= 1 then return "…" end

    return "…" .. vim.fn.strcharpart(text, text_width - width + 1, width - 1)
  end

  local function get_footer_chunk_text(footer, index)
    local chunk = type(footer) == "table" and footer[index] or nil

    if type(chunk) == "table" then return chunk[1] or "" end
    if type(chunk) == "string" then return chunk end

    return ""
  end

  local function format_footer_name(raw, fallback)
    local source_name = trim(raw)

    if source_name == "" then source_name = fallback end

    source_name = source_name:gsub("^┤%s*", ""):gsub("%s*├$", "")
    source_name = source_name:gsub("[%z%s]", " ")

    return ("┤ %s ├"):format(source_name)
  end

  local function format_footer_stats(raw)
    local stats = trim(raw)

    if stats == "" then return nil end
    if not stats:find("╼", 1, true) and not stats:find("╾", 1, true) then return nil end

    stats = stats:gsub("│", "|")
    stats = stats:gsub("%s*|%s*", "|")
    stats = stats:gsub("^|", ""):gsub("|$", "")

    if stats == "" then return nil end

    return ("│ %s │"):format(stats:gsub("|", " │ "))
  end

  local function set_custom_footer()
    if not mini_pick.is_picker_active() then return end

    local state = mini_pick.get_picker_state()
    local opts = mini_pick.get_picker_opts()

    if not state or not opts then return end

    local win_id = state.windows.main

    if not vim.api.nvim_win_is_valid(win_id) then return end

    local win_config = vim.api.nvim_win_get_config(win_id)
    local footer = win_config.footer
    local footer_len = type(footer) == "table" and #footer or 0
    local win_width = vim.api.nvim_win_get_width(win_id)
    local left = format_footer_name(get_footer_chunk_text(footer, 1), opts.source.name or "---")
    local right = format_footer_stats(get_footer_chunk_text(footer, footer_len))
    local border_hl = state.is_busy and "MiniPickBorderBusy" or "MiniPickBorder"
    local border = win_config.border or {}
    local fill = border[6]

    if type(fill) == "table" then fill = fill[1] end
    if fill == nil or fill == "" then fill = "─" end

    left = fit_to_width(left, win_width)

    local current_left = get_footer_chunk_text(footer, 1)
    local current_right = footer_len > 1 and get_footer_chunk_text(footer, footer_len) or nil

    if current_left == left and current_right == (right or "") then return end

    local footer_config = {
      footer = {
        { left, "MiniPickBorderText" },
      },
      footer_pos = "left",
    }

    if right ~= nil then
      local padding = win_width - vim.fn.strchars(left) - vim.fn.strchars(right)

      if padding > 0 then
        table.insert(footer_config.footer, { fill:rep(padding), border_hl })
        table.insert(footer_config.footer, { right, "MiniPickBorderText" })
      end
    end

    vim.api.nvim_win_set_config(win_id, footer_config)
  end

  local function refresh_pick_style()
    set_transparent_text()
    set_custom_footer()
  end

  local function stop_footer_timer()
    if footer_timer == nil then return end

    footer_timer:stop()
    footer_timer:close()
    footer_timer = nil
  end

  local function start_footer_timer()
    stop_footer_timer()

    footer_timer = uv.new_timer()
    footer_timer:start(
      0,
      50,
      vim.schedule_wrap(function()
        if not mini_pick.is_picker_active() then
          stop_footer_timer()
          return
        end

        refresh_pick_style()
      end)
    )
  end

  local function center_picker()
    local has_tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
    local has_statusline = vim.o.laststatus > 0
    local top_offset = has_tabline and 1 or 0
    local max_height = vim.o.lines - vim.o.cmdheight - top_offset - (has_statusline and 1 or 0)
    local width = math.floor(0.618 * vim.o.columns)
    local height = math.floor(0.618 * max_height)

    return {
      anchor = "NW",
      border = "rounded",
      col = math.floor(0.5 * (vim.o.columns - width)),
      height = height,
      row = top_offset + math.floor(0.5 * (max_height - height)),
      width = width,
    }
  end

  mini_pick.setup {
    window = {
      config = center_picker,
      prompt_caret = "┃",
      prompt_prefix = "╼  ",
      prompt_suffix = " ╾",
    },
  }

  set_transparent_text()

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = style_group,
    desc = "Keep mini.pick prompt and footer transparent",
    callback = refresh_pick_style,
  })

  vim.api.nvim_create_autocmd("User", {
    group = style_group,
    pattern = "MiniPickStart",
    desc = "Start mini.pick footer styling refresh",
    callback = function()
      refresh_pick_style()
      start_footer_timer()
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = style_group,
    pattern = { "MiniPickMatch", "MiniPickStop" },
    desc = "Refresh or stop mini.pick footer styling",
    callback = function()
      if mini_pick.is_picker_active() then
        refresh_pick_style()
        return
      end

      stop_footer_timer()
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = style_group,
    desc = "Refresh mini.pick footer styling on resize",
    callback = function()
      if mini_pick.is_picker_active() then refresh_pick_style() end
    end,
  })
end

local function setup_mini_extra()
  local ok, mini_extra = pcall(require, "mini.extra")

  if not ok then return end

  mini_extra.setup()
end

local function setup_notify()
  local ok, notify = pcall(require, "notify")

  if not ok then return end

  notify.setup {
    background_colour = "#000000",
    merge_duplicates = true,
    render = "wrapped-compact",
    stages = "fade_in_slide_out",
    timeout = 3000,
    top_down = true,
  }
end

local function setup_noice()
  local ok, noice = pcall(require, "noice")

  if not ok then return end

  noice.setup {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_search = false,
    },
    notify = {
      enabled = true,
      view = "notify",
    },
    popupmenu = {
      enabled = false,
    },
    presets = {
      long_message_to_split = true,
    },
  }
end

local function setup_neotree()
  local ok, neo_tree = pcall(require, "neo-tree")

  if not ok then return end

  neo_tree.setup {
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
    },
  }
end

local function setup_toggleterm()
  local ok, toggleterm = pcall(require, "toggleterm")

  if not ok then return end

  toggleterm.setup {
    close_on_exit = true,
    direction = "float",
    float_opts = {
      border = "rounded",
    },
    hide_numbers = true,
    persist_mode = true,
    shade_terminals = false,
    start_in_insert = true,
  }
end

local function setup_tmux()
  local ok, tmux = pcall(require, "tmux")

  if not ok then return end

  tmux.setup {
    copy_sync = {
      enable = true,
      sync_clipboard = false,
    },
  }
end

setup_colorscheme()
setup_copilot()
setup_copilot_chat()
setup_render_markdown()
setup_mini_clue()
setup_mini_pick()
setup_mini_extra()
setup_mini_tabline()
setup_notify()
setup_noice()
setup_neotree()
setup_toggleterm()
setup_tmux()
