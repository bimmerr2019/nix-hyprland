-- Create base capabilities that will be used by all LSP servers
local base_capabilities = vim.lsp.protocol.make_client_capabilities()
base_capabilities = require('cmp_nvim_lsp').default_capabilities(base_capabilities)
base_capabilities.textDocument.semanticTokens = nil

-- Create a function for common LSP setup
local function create_capabilities()
    local caps = vim.deepcopy(base_capabilities)
    return caps
end

local lspconfig = require("lspconfig")

require('lspconfig').lua_ls.setup {
  capabilities = create_capabilities(),
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
  capabilities = create_capabilities(),
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

require('lspconfig').marksman.setup {
  capabilities = create_capabilities()
}

require('lspconfig').rust_analyzer.setup {
  capabilities = create_capabilities()
}

require('lspconfig').yamlls.setup {
  capabilities = create_capabilities()
}

require('lspconfig').bashls.setup {
  capabilities = create_capabilities(),
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
      shellcheckPath = "shellcheck",
      shellcheckArguments = {},
      explainshellEndpoint = "",
      includeAllWorkspaceSymbols = true,
      highlightParsingErrors = true,
    },
  },
  filetypes = { "sh", "bash" },
  cmd = { "bash-language-server", "start" }
}

require("lspconfig").nixd.setup({
  capabilities = (function()
    local capabilities = create_capabilities()
    -- Explicitly disable semantic tokens for nixd
    capabilities.textDocument.semanticTokens = nil
    capabilities.textDocument.semanticTokensProvider = nil
    return capabilities
  end)(),
  on_init = function(client)
    -- Disable semantic tokens on init
    client.server_capabilities.semanticTokensProvider = nil
  end,
  cmd = { "nixd" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
        expr2 = string.format('import (builtins.getFlake "/home/%s/zaneyos").inputs.nixpkgs { }', vim.g.username)
      },
      formatting = {
        command = { "alejandra" },
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
  on_attach = function(client, _)
    -- Disable semantic tokens on attach
    client.server_capabilities.semanticTokensProvider = nil
    -- Enable formatting capability
    client.server_capabilities.documentFormattingProvider = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "nix",
  callback = function()
    vim.keymap.set('n', '<leader>fg', function()
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
