local group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })
local languages = require "config.languages.registry"

local function executable(cmd)
  if type(cmd) == "table" then
    for _, candidate in ipairs(cmd) do
      if vim.fn.executable(candidate) == 1 then return true end
    end

    return false
  end

  return vim.fn.executable(cmd) == 1
end

local function buf_map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, {
    buffer = bufnr,
    desc = desc,
  })
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

for _, language in ipairs(languages) do
  for _, server in ipairs(language.lsp or {}) do
    if server.config then vim.lsp.config(server.name, server.config) end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  desc = "Native LSP defaults",
  callback = function(args)
    if not args.data or not args.data.client_id then return end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if not client then return end

    buf_map(bufnr, "n", "gd", vim.lsp.buf.definition, "Go to definition")
    buf_map(bufnr, "n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    buf_map(bufnr, "n", "gr", vim.lsp.buf.references, "References")
    buf_map(bufnr, "n", "<leader>lR", function() require("telescope.builtin").lsp_references() end, "References picker")
    buf_map(bufnr, "n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    buf_map(bufnr, "n", "K", vim.lsp.buf.hover, "Hover")
    buf_map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    buf_map(bufnr, "n", "<leader>ca", vim.lsp.buf.code_action, "Code action")

    if client:supports_method "textDocument/signatureHelp" then
      buf_map(bufnr, "i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
    end

    if client:supports_method "textDocument/inlayHint" then
      buf_map(bufnr, "n", "<leader>uh", function()
        local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
      end, "Toggle inlay hints")
    end

    if client:supports_method "textDocument/completion" then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      buf_map(bufnr, "i", "<C-Space>", vim.lsp.completion.get, "Trigger completion")
    end

    if client:supports_method "textDocument/codeLens" and not vim.b[bufnr].lsp_codelens_refresh then
      buf_map(bufnr, "n", "<leader>cl", vim.lsp.codelens.run, "Run code lens")
      vim.b[bufnr].lsp_codelens_refresh = true

      pcall(vim.lsp.codelens.enable, true, { bufnr = bufnr })
    end
  end,
})

for _, language in ipairs(languages) do
  for _, server in ipairs(language.lsp or {}) do
    if executable(server.cmd) then pcall(vim.lsp.enable, server.name) end
  end
end
