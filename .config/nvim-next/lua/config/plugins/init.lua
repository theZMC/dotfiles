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

local function setup_telescope()
  local ok, telescope = pcall(require, "telescope")

  if not ok then return end

  telescope.setup {
    defaults = {
      path_display = { "smart" },
    },
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
setup_mini_tabline()
setup_notify()
setup_noice()
setup_neotree()
setup_telescope()
setup_tmux()
