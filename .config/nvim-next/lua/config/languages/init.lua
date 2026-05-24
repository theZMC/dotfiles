local group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })
local languages = require "config.languages.registry"

-- Neovim 0.12 renders built-in codelens as virtual lines above the target line.
-- Patch only the renderer's extmark call to place lenses at end-of-line instead.
local function patch_codelens_display()
  local upvalue_name, provider = debug.getupvalue(vim.lsp.codelens.get, 1)

  if upvalue_name ~= "Provider" or type(provider) ~= "table" or provider._inline_display_patched then return end

  local api_upvalue_name, api = debug.getupvalue(provider.on_win, 1)

  if api_upvalue_name ~= "api" or type(api) ~= "table" then return end

  local patched_api = setmetatable({
    nvim_buf_set_extmark = function(bufnr, namespace, row, col, opts)
      if opts and opts.virt_lines and opts.virt_lines_above then
        local virt_text = vim.deepcopy(opts.virt_lines[1] or {})

        if #virt_text > 0 then
          table.remove(virt_text, 1)
          table.insert(virt_text, 1, { "  ", "LspCodeLensSeparator" })
        end

        opts = vim.deepcopy(opts)
        opts.virt_lines = nil
        opts.virt_lines_above = nil
        opts.virt_lines_overflow = nil
        opts.virt_text = virt_text
        opts.virt_text_pos = "eol"
      end

      return api.nvim_buf_set_extmark(bufnr, namespace, row, col, opts)
    end,
  }, { __index = api })

  debug.setupvalue(provider.on_win, 1, patched_api)
  provider._inline_display_patched = true
end

local function executable(cmd)
  if type(cmd) == "table" then
    for _, candidate in ipairs(cmd) do
      if vim.fn.executable(candidate) == 1 then return true end
    end

    return false
  end

  return vim.fn.executable(cmd) == 1
end

patch_codelens_display()

local function buf_map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, {
    buffer = bufnr,
    desc = desc,
  })
end

local function document_symbol_items(bufnr)
  local results = vim.lsp.buf_request_sync(
    bufnr,
    "textDocument/documentSymbol",
    { textDocument = vim.lsp.util.make_text_document_params(bufnr) },
    1000
  ) or {}
  local items = {}
  local seen = {}

  for client_id, response in pairs(results) do
    local client = vim.lsp.get_client_by_id(client_id)

    if client and response.result then
      for _, item in ipairs(vim.lsp.util.symbols_to_items(response.result, bufnr, client.offset_encoding)) do
        local key = table.concat({ item.filename or "", item.lnum or 0, item.col or 0, item.text or "" }, ":")

        if not seen[key] then
          seen[key] = true
          table.insert(items, item)
        end
      end
    end
  end

  table.sort(items, function(a, b)
    if a.lnum == b.lnum then return a.col < b.col end

    return a.lnum < b.lnum
  end)

  return items
end

local function jump_document_symbol(bufnr, step)
  local items = document_symbol_items(bufnr)

  if #items == 0 then
    vim.notify("No document symbols", vim.log.levels.INFO)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2] + 1
  local target

  if step > 0 then
    for _, item in ipairs(items) do
      if item.lnum > row or (item.lnum == row and item.col > col) then
        target = item
        break
      end
    end

    target = target or items[1]
  else
    for i = #items, 1, -1 do
      local item = items[i]

      if item.lnum < row or (item.lnum == row and item.col < col) then
        target = item
        break
      end
    end

    target = target or items[#items]
  end

  vim.api.nvim_win_set_cursor(0, { target.lnum, math.max(target.col - 1, 0) })
end

vim.lsp.config("*", {
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
      semanticTokens = {
        multilineTokenSupport = true,
      },
    },
  },
})

for _, language in pairs(languages) do
  for _, server in ipairs(language.lsp or {}) do
    if server.config then vim.lsp.config(server.name, server.config) end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  desc = "Native LSP defaults",
  callback = function(args)
    if not args.data or not args.data.client_id then return end

    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if not client then return end

    local bufnr = args.buf
    local pick = require "config.pick"

    local function map_if(method, mode, lhs, rhs, desc)
      if client:supports_method(method) then buf_map(bufnr, mode, lhs, rhs, desc) end
    end

    buf_map(bufnr, "n", "<leader>li", "<cmd>LspInfo<cr>", " LSP Info")
    buf_map(bufnr, "n", "<leader>lf", "<cmd>Format<cr>", "󰁨 Format Document")

    map_if("textDocument/hover", "n", "K", vim.lsp.buf.hover, "󰋽 Hover Document")
    map_if("textDocument/definition", "n", "gd", vim.lsp.buf.definition, "Definition")
    map_if("textDocument/declaration", "n", "gD", vim.lsp.buf.declaration, "Declaration")
    map_if("textDocument/typeDefinition", "n", "gy", vim.lsp.buf.type_definition, "Type Definition")
    map_if("textDocument/implementation", "n", "gri", vim.lsp.buf.implementation, "Implementation")
    map_if("textDocument/references", "n", "grr", function() pick.lsp "references" end, "󰈇 References")
    map_if("textDocument/references", "n", "<leader>lR", function() pick.lsp "references" end, "󰈇 References")
    map_if("textDocument/rename", "n", "grn", vim.lsp.buf.rename, "󰑕 Rename")
    map_if("textDocument/rename", "n", "<leader>lr", vim.lsp.buf.rename, "󰑕 Rename")
    map_if("textDocument/codeAction", { "n", "x" }, "gra", vim.lsp.buf.code_action, "󰌵 Code Actions")
    map_if("textDocument/codeAction", { "n", "x" }, "<leader>la", vim.lsp.buf.code_action, "󰌵 Code Actions")
    map_if(
      "textDocument/codeAction",
      "n",
      "<leader>lA",
      function()
        vim.lsp.buf.code_action {
          context = {
            diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 }),
            only = { "source" },
          },
        }
      end,
      "󰘦 Source Actions"
    )
    map_if("textDocument/signatureHelp", "n", "<leader>lh", vim.lsp.buf.signature_help, "󰋖 Signature Help")
    map_if(
      "textDocument/documentSymbol",
      "n",
      "[y",
      function() jump_document_symbol(bufnr, -1) end,
      "Document Symbol Previous"
    )
    map_if(
      "textDocument/documentSymbol",
      "n",
      "]y",
      function() jump_document_symbol(bufnr, 1) end,
      "Document Symbol Next"
    )
    map_if("textDocument/documentSymbol", "n", "gO", vim.lsp.buf.document_symbol, "󰀫 Document Symbol")
    map_if(
      "textDocument/documentSymbol",
      "n",
      "<leader>ls",
      function() pick.lsp "document_symbol" end,
      "󰀫 Document Symbols"
    )
    map_if("textDocument/documentSymbol", "n", "<leader>lS", vim.lsp.buf.document_symbol, "󰙅 Symbols Outline")
    map_if(
      "workspace/symbol",
      "n",
      "<leader>lG",
      function() pick.lsp "workspace_symbol_live" end,
      "󰒋 Workspace Symbols"
    )

    if client:supports_method "textDocument/inlayHint" then
      buf_map(bufnr, "n", "<leader>uh", function()
        local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
      end, "󰞋 Toggle LSP Inlay Hints")
    end

    if client:supports_method "textDocument/completion" then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      buf_map(bufnr, "i", "<C-Space>", vim.lsp.completion.get, "Trigger completion")
    end

    if client:supports_method "textDocument/codeLens" and not vim.b[bufnr].lsp_codelens_refresh then
      buf_map(bufnr, "n", "<leader>uL", function()
        local enabled = vim.lsp.codelens.is_enabled { bufnr = bufnr }
        vim.lsp.codelens.enable(not enabled, { bufnr = bufnr })
      end, "󰛢 Toggle CodeLens")
      vim.b[bufnr].lsp_codelens_refresh = true

      pcall(vim.lsp.codelens.enable, true, { bufnr = bufnr })
    end
  end,
})

for _, language in pairs(languages) do
  for _, server in ipairs(language.lsp or {}) do
    if executable(server.cmd) then pcall(vim.lsp.enable, server.name) end
  end
end
