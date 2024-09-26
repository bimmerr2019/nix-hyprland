{ config, pkgs, ... }:

let
  tmuxPluginManager = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tpm";
    version = "v3.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tpm";
      rev = "v3.1.0";
      sha256 = "18i499hhxly1r2bnqp9wssh0p1v391cxf10aydxaa7mdmrd3vqh9";
    };
  };
  
  themepack = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "themepack";
    version = "1.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "jimeh";
      repo = "tmux-themepack";
      rev = "7c59902f64dcd7ea356e891274b21144d1ea5948";
      sha256 = "sha256-c5EGBrKcrqHWTKpCEhxYfxPeERFrbTuDfcQhsUAbic4=";
    };
  };
in
{
  programs.tmux = {
    enable = true;
    plugins = [
      tmuxPluginManager
      {
        plugin = themepack;
        extraConfig = ''
          set -g @themepack 'powerline/default/cyan'
        '';
      }
    ];
    extraConfig = ''
      # Ensure 256 colors
      set -g default-terminal "screen-256color"

      # Other plugins
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'christoomey/vim-tmux-navigator'
      set -g @plugin 'tmux-plugins/tmux-resurrect'
      set -g @plugin 'tmux-plugins/tmux-continuum'

      # Plugin configurations
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-dir '~/.tmux/resurrect'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15'

      # Your existing tmux configurations
      unbind C-a
      unbind C-b
      set -g prefix C-a
      bind-key C-a send-prefix

      # v and h are not binded by default, but we never know in the next versions
      unbind v
      unbind -

      unbind % # Split vertically
      unbind '"' # Split horizontally
      bind v split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5

      bind -r m resize-pane -Z

      set -g mouse on
      set -g status-keys vi
      set -g mode-keys vi

      unbind n #DEFAULT KEY: Move to next window

      bind n command-prompt "rename-window '%%'"

      set -g base-index 1
      set-window-option -g pane-base-index 1

      # Go through every window with ALT+k and ALT+j
      bind -n M-j previous-window
      bind -n M-k next-window

      # yazi needs this:
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      set-window-option -g mode-keys vi

      bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
      bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

      # remove delay for exiting insert mode with ESC in Neovim
      set -sg escape-time 10

      # Restore session on tmux start
      set-hook -g after-new-session 'run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh'

      # this code interferes with tmux-vim-navigator for tmux panes up and down, left and right work.
      # for up and down use prefix-arrow key, otherwise telescope wont respond to ctrl-j and k in nvim
      bind-key -n C-j send-keys C-j
      bind-key -n C-k send-keys C-k

      # Rerun the themepack
      run-shell ${themepack}/share/tmux-plugins/themepack/themepack.tmux

      # Initialize TPM (keep this at the very bottom)
      run '${tmuxPluginManager}/share/tmux-plugins/tpm'
    '';
  };
}
