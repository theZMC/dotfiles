local M = {
  github_api_url = "https://api.github.com/repos/datreeio/CRDs-catalog/git/trees/main?recursive=1",
  schema_base_url = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main",
}

local cached_schema_paths

local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = "K8s Schema" }) end

local function parse_schema_paths(body)
  local ok, decoded = pcall(vim.json.decode, body)
  if not ok or type(decoded) ~= "table" or type(decoded.tree) ~= "table" then
    return nil, "Failed to decode the CRD catalog response."
  end

  local schema_paths = {}
  for _, entry in ipairs(decoded.tree) do
    if entry.type == "blob" and entry.path:match "%.json$" then table.insert(schema_paths, entry.path) end
  end

  table.sort(schema_paths)
  return schema_paths
end

local function upsert_schema_modeline(bufnr, schema_url)
  local modeline = "# yaml-language-server: $schema=" .. schema_url
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(line_count, 20), false)

  for index, line in ipairs(lines) do
    if line:match "^#%s*yaml%-language%-server:%s*%$schema=" then
      vim.api.nvim_buf_set_lines(bufnr, index - 1, index, false, { modeline })
      return modeline, "updated"
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { modeline })
  return modeline, "inserted"
end

local function select_schema(schema_paths)
  vim.ui.select(schema_paths, {
    prompt = "Select Kubernetes schema:",
    format_item = function(item) return item:gsub("%.json$", "") end,
  }, function(selection)
    if not selection then
      notify("Schema selection canceled.", vim.log.levels.WARN)
      return
    end

    local modeline, action = upsert_schema_modeline(0, M.schema_base_url .. "/" .. selection)
    local action_text = action == "updated" and "Updated" or "Added"
    notify(action_text .. " schema modeline: " .. modeline)
  end)
end

function M.select(opts)
  opts = opts or {}

  if not opts.refresh and cached_schema_paths then
    select_schema(cached_schema_paths)
    return
  end

  if vim.fn.executable "curl" ~= 1 then
    notify("`curl` is required to fetch Kubernetes CRD schemas.", vim.log.levels.ERROR)
    return
  end

  notify "Fetching Kubernetes CRD schemas..."
  vim.system({ "curl", "-fsSL", M.github_api_url }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local error_output = result.stderr ~= "" and result.stderr or result.stdout
        notify("Failed to fetch Kubernetes CRD schemas: " .. error_output, vim.log.levels.ERROR)
        return
      end

      local schema_paths, err = parse_schema_paths(result.stdout)
      if not schema_paths then
        notify(err, vim.log.levels.ERROR)
        return
      end

      cached_schema_paths = schema_paths
      select_schema(schema_paths)
    end)
  end)
end

return M
