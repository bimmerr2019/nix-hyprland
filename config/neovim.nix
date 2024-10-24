{
  pkgs,
  username,
  host,
  inputs,
  ...
}: let
  finecmdline = pkgs.vimUtils.buildVimPlugin {
    name = "fine-cmdline";
    src = inputs.fine-cmdline;
  };
  pythonConfigs = import ./python.nix { inherit pkgs; };
in {
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      extraPackages = with pkgs; [
        nixd # Add this
        bash-language-server
        shellcheck
        lua-language-server
        gopls
        xclip
        wl-clipboard
        luajitPackages.lua-lsp
        nil
        rust-analyzer
        yaml-language-server
        pythonConfigs.basePython  # This already includes python, pip, pylint, black, etc.
        pyright
        marksman
        alejandra
      ];
      plugins = with pkgs.vimPlugins; [
        alpha-nvim
        auto-session
        bufferline-nvim
        dressing-nvim
        indent-blankline-nvim
        nui-nvim
        finecmdline
        nvim-treesitter.withAllGrammars
        lualine-nvim
        nvim-autopairs
        nvim-web-devicons
        nvim-cmp
        nvim-surround
        nvim-lspconfig
        nvim-dap  # For debugging
        nvim-dap-python  # Python specific debug adapter
        neotest  # For running tests
        neotest-python  # Python test adapter
        cmp-nvim-lsp
        cmp-buffer
        luasnip
        cmp_luasnip
        friendly-snippets
        lspkind-nvim
        comment-nvim
        nvim-ts-context-commentstring
        plenary-nvim
        neodev-nvim
        luasnip
        telescope-nvim
        todo-comments-nvim
        nvim-tree-lua
        telescope-fzf-native-nvim
        vim-tmux-navigator
        vim-lastplace
      ];
      extraConfig = ''
        set noemoji
        set termguicolors
        nnoremap : <cmd>FineCmdline<CR>
        lua << EOF
        local actions = require('telescope.actions')
        require('telescope').setup{
          defaults = {
            mappings = {
              i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
              },
            },
          }
        }
        EOF
      '';
      extraLuaConfig = ''
        vim.g.username = "${username}"
        vim.g.host = "${host}"

        ${builtins.readFile ./nvim/options.lua}
        ${builtins.readFile ./nvim/keymaps.lua}
        ${builtins.readFile ./nvim/plugins/alpha.lua}
        ${builtins.readFile ./nvim/plugins/autopairs.lua}
        ${builtins.readFile ./nvim/plugins/auto-session.lua}
        ${builtins.readFile ./nvim/plugins/comment.lua}
        ${builtins.readFile ./nvim/plugins/cmp.lua}
        ${builtins.readFile ./nvim/plugins/lsp.lua}
        ${builtins.readFile ./nvim/plugins/nvim-tree.lua}
        ${builtins.readFile ./nvim/plugins/telescope.lua}
        ${builtins.readFile ./nvim/plugins/todo-comments.lua}
        ${builtins.readFile ./nvim/plugins/treesitter.lua}
        ${builtins.readFile ./nvim/plugins/fine-cmdline.lua}
        require("ibl").setup()
        require("bufferline").setup{}
        require('lualine').setup({
          options = {
            icons_enabled = true,
            theme = {
              normal = {
                a = { bg = '#799a63', fg = '#000000' },  -- Using the actual hex color you found
                b = { bg = '#5e7b4f', fg = '#ffffff' },  -- Slightly darker variant
                c = { bg = '#4a613e', fg = '#ffffff' }   -- Even darker variant
              },
              insert = {
                a = { bg = '#799a63', fg = '#000000' },
                b = { bg = '#5e7b4f', fg = '#ffffff' },
                c = { bg = '#4a613e', fg = '#ffffff' }
              },
              visual = {
                a = { bg = '#799a63', fg = '#000000' },
                b = { bg = '#5e7b4f', fg = '#ffffff' },
                c = { bg = '#4a613e', fg = '#ffffff' }
              },
              replace = {
                a = { bg = '#799a63', fg = '#000000' },
                b = { bg = '#5e7b4f', fg = '#ffffff' },
                c = { bg = '#4a613e', fg = '#ffffff' }
              }
            }
          },
          sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff', 'diagnostics'},
            lualine_c = {'filename'},
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'}
          }
        })
      '';
    };
  };
}
