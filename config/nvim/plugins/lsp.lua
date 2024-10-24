local lspconfig = require("lspconfig")

require('lspconfig').lua_ls.setup { -- Add this config block for Lua
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

require('lspconfig').pyright.setup({
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "basic"  -- Can be "off", "basic", or "strict"
      }
    }
  },
  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  end,
})

require('lspconfig').marksman.setup {}
require('lspconfig').rust_analyzer.setup {}
require('lspconfig').yamlls.setup {}

require('lspconfig').bashls.setup {
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
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
        expr2 = string.format('import (builtins.getFlake "/home/%s/zaneyos").inputs.nixpkgs { }', vim.g.username)
      },
      formatting = {
        command = { "alejandra" }, -- or nixfmt or nixpkgs-fmt
      },
      options = {
        nixos = {
            expr = string.format('(builtins.getFlake "/home/%s/zaneyos").nixosConfigurations.%s.options', vim.g.username, vim.g.host),
        },
        home_manager = {
            expr = string.format('(builtins.getFlake "/home/%s/zaneyos").homeConfigurations.%s.options', vim.g.username, vim.g.username),
        },
      },
    },
  },
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
