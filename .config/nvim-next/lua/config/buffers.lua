local M = {}

local function listed_buffers()
  local buffers = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_loaded(bufnr) then table.insert(buffers, bufnr) end
  end

  table.sort(buffers)

  return buffers
end

function M.cycle(step, count)
  local buffers = listed_buffers()

  if #buffers == 0 then return end

  local current = vim.api.nvim_get_current_buf()
  local index = 1

  for i, bufnr in ipairs(buffers) do
    if bufnr == current then
      index = i
      break
    end
  end

  local next_index = ((index - 1 + (step * count)) % #buffers) + 1
  vim.api.nvim_set_current_buf(buffers[next_index])
end

function M.pick_to_close()
  local items = {}

  for _, bufnr in ipairs(listed_buffers()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    local label = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":~:.")

    if vim.bo[bufnr].modified then label = label .. " [+]" end

    table.insert(items, {
      bufnr = bufnr,
      label = ("%d: %s"):format(bufnr, label),
    })
  end

  if #items == 0 then return end

  vim.ui.select(items, {
    prompt = "Close buffer",
    format_item = function(item) return item.label end,
  }, function(choice)
    if choice then vim.api.nvim_buf_delete(choice.bufnr, { force = false }) end
  end)
end

function M.close_current() vim.cmd "confirm bdelete" end

return M
