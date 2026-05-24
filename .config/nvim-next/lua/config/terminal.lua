local M = {}

local shell_terminal
local lazygit_terminal

local function float_dimensions()
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.85)

  return width, height
end

local function float_opts()
  return {
    border = "rounded",
    col = function()
      local width = float_dimensions()

      return math.floor((vim.o.columns - width) / 2)
    end,
    height = function()
      local _, height = float_dimensions()

      return height
    end,
    row = function()
      local _, height = float_dimensions()

      return math.floor((vim.o.lines - height) / 2 - 1)
    end,
    width = function()
      local width = float_dimensions()

      return width
    end,
  }
end

local function terminal_class()
  local ok, terminal = pcall(require, "toggleterm.terminal")

  if not ok then
    vim.notify("toggleterm.nvim is not available", vim.log.levels.ERROR)
    return
  end

  return terminal.Terminal
end

local function set_terminal_keymaps(term, close)
  local bufnr = term.bufnr

  if vim.b[bufnr].user_terminal_keymaps then return end

  vim.keymap.set("t", "<Esc><Esc>", [[<C-\\><C-n>]], {
    buffer = bufnr,
    desc = "Exit terminal mode",
  })

  vim.keymap.set("n", "q", close, {
    buffer = bufnr,
    desc = "Close terminal",
  })

  vim.b[bufnr].user_terminal_keymaps = true
end

local function configure_terminal(term, close)
  set_terminal_keymaps(term, close)
  vim.cmd.startinsert()
end

local function lazygit_cwd()
  local cwd = vim.fn.getcwd()
  local name = vim.api.nvim_buf_get_name(0)

  if name ~= "" then
    local stat = vim.uv.fs_stat(name)

    if stat and stat.type == "directory" then
      cwd = name
    elseif stat and stat.type == "file" then
      cwd = vim.fs.dirname(name)
    end
  end

  local result = vim
    .system({ "git", "rev-parse", "--show-toplevel" }, {
      cwd = cwd,
      text = true,
    })
    :wait()

  if result.code == 0 and result.stdout then return vim.trim(result.stdout) end

  return cwd
end

local function get_shell_terminal()
  if shell_terminal then return shell_terminal end

  local Terminal = terminal_class()

  if not Terminal then return end

  shell_terminal = Terminal:new {
    direction = "float",
    float_opts = float_opts(),
    hidden = true,
    on_open = function(term)
      configure_terminal(term, function() term:close() end)
    end,
  }

  return shell_terminal
end

local function get_lazygit_terminal()
  if lazygit_terminal then return lazygit_terminal end

  local Terminal = terminal_class()

  if not Terminal then return end

  lazygit_terminal = Terminal:new {
    close_on_exit = true,
    cmd = "lazygit",
    direction = "float",
    dir = lazygit_cwd(),
    float_opts = float_opts(),
    hidden = true,
    on_close = function()
      lazygit_terminal = nil
    end,
    on_open = function(term)
      configure_terminal(term, function() term:shutdown() end)
    end,
  }

  return lazygit_terminal
end

function M.toggle()
  local term = get_shell_terminal()

  if not term then return end

  term:toggle()
end

function M.lazygit()
  if vim.fn.executable "lazygit" == 0 then
    vim.notify("lazygit is not installed or not on PATH", vim.log.levels.ERROR)
    return
  end

  local term = get_lazygit_terminal()

  if not term then return end

  if term:is_open() then
    term:shutdown()
    return
  end

  term:open()
end

return M
