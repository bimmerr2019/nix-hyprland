local lspconfig = require("lspconfig")

require 'lspconfig'.lua_ls.setup { -- Add this config block for Lua
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        }
      }
    }
  }
}

require 'lspconfig'.pyright.setup {}
-- require 'lspconfig'.nil_ls.setup {}
require 'lspconfig'.marksman.setup {}
require 'lspconfig'.rust_analyzer.setup {}
require 'lspconfig'.yamlls.setup {}

require 'lspconfig'.bashls.setup {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
      shellcheckPath = "shellcheck", -- make sure shellcheck is installed
      shellcheckArguments = {},
      explainshellEndpoint = "",     -- optional: you can set up explainshell.com
      includeAllWorkspaceSymbols = true,
      highlightParsingErrors = true,
      -- optional: format on save
      -- formatOnSave = true,
    },
  },
  filetypes = { "sh", "bash" },
  cmd = { "bash-language-server", "start" }
}

require("lspconfig").nixd.setup({
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  cmd = { "nixd" },
  filetypes = { "nix" },
  on_attach = function(client, _) -- Change bufnr to _ since we're not using it
    -- Enable formatting capability
    client.server_capabilities.documentFormattingProvider = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "nix",
  callback = function()
    vim.keymap.set('n', '<leader>fg', function()
      -- Remove unused variables
      vim.api.nvim_exec([[
        let view = winsaveview()
        %!alejandra -q
        call winrestview(view)
      ]], false)
    end, { buffer = true, noremap = true, silent = true })
  end
})

-- Add key mapping for format
vim.keymap.set('n', '<leader>fg', function()
  vim.lsp.buf.format()
end, { noremap = true, silent = true })
