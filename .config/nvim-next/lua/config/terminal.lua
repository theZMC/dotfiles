local M = {}

local shell_state = {
  buf = nil,
  win = nil,
}

local lazygit_state = {
  buf = nil,
  job = nil,
  win = nil,
}

local function is_valid_buf(buf) return buf and vim.api.nvim_buf_is_valid(buf) end

local function is_valid_win(win) return win and vim.api.nvim_win_is_valid(win) end

local function float_opts(width_ratio, height_ratio)
  local width = math.floor(vim.o.columns * (width_ratio or 0.9))
  local height = math.floor(vim.o.lines * (height_ratio or 0.85))

  return {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2 - 1),
    style = "minimal",
    border = "rounded",
  }
end

local function set_terminal_keymaps(bufnr, close)
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

local function close_shell_window()
  if is_valid_win(shell_state.win) then vim.api.nvim_win_close(shell_state.win, true) end

  shell_state.win = nil
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

local function job_running(job) return job and vim.fn.jobwait({ job }, 0)[1] == -1 end

local function close_lazygit(stop_job)
  local buf = lazygit_state.buf
  local job = lazygit_state.job
  local win = lazygit_state.win

  lazygit_state.buf = nil
  lazygit_state.job = nil
  lazygit_state.win = nil

  if stop_job and job_running(job) then pcall(vim.fn.jobstop, job) end

  if is_valid_win(win) then pcall(vim.api.nvim_win_close, win, true) end

  if is_valid_buf(buf) then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
end

function M.toggle()
  if is_valid_win(shell_state.win) then
    close_shell_window()
    return
  end

  if not is_valid_buf(shell_state.buf) then
    shell_state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[shell_state.buf].bufhidden = "hide"
  end

  shell_state.win = vim.api.nvim_open_win(shell_state.buf, true, float_opts())

  if vim.bo[shell_state.buf].buftype ~= "terminal" then
    vim.cmd.terminal()
    shell_state.buf = vim.api.nvim_get_current_buf()
    vim.bo[shell_state.buf].bufhidden = "hide"
    set_terminal_keymaps(shell_state.buf, close_shell_window)
  end

  vim.cmd.startinsert()
end

function M.lazygit()
  if vim.fn.executable "lazygit" == 0 then
    vim.notify("lazygit is not installed or not on PATH", vim.log.levels.ERROR)
    return
  end

  if is_valid_win(lazygit_state.win) or is_valid_buf(lazygit_state.buf) then
    close_lazygit(true)
    return
  end

  lazygit_state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[lazygit_state.buf].bufhidden = "wipe"

  lazygit_state.win = vim.api.nvim_open_win(lazygit_state.buf, true, float_opts())
  set_terminal_keymaps(lazygit_state.buf, function() close_lazygit(true) end)

  lazygit_state.job = vim.fn.jobstart({ "lazygit" }, {
    term = true,
    cwd = lazygit_cwd(),
    on_exit = function()
      vim.schedule(function() close_lazygit(false) end)
    end,
  })

  vim.cmd.startinsert()
end

return M
