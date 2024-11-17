{ config, pkgs, ... }:

let
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
    mouse = true;
    keyMode = "vi";
    shortcut = "a";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    escapeTime = 10;
    historyLimit = 100000;
    aggressiveResize = true;
    baseIndex = 1;
    newSession = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      {
        plugin = themepack;
        extraConfig = ''
          set -g @themepack 'powerline/default/cyan'
          # set -g @themepack 'powerline/default/orange'
          # set -g @themepack 'basic'
        '';
      }
      {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-dir '~/.tmux/resurrect'
          '';
      }
    ];
    extraConfig = ''
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

      unbind n #DEFAULT KEY: Move to next window
      bind n command-prompt "rename-window '%%'"

      # Go through every window with ALT+k and ALT+j
      bind -n M-j previous-window
      bind -n M-k next-window

      #bind -n M-J swap-window -d -t -1; send-keys -X select-pane -L #Swap tmux windows
      #bind -n M-K swap-window -d -t +1; send-keys -X select-pane -L #Swap tmux windows

      # yazi needs this:
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      set-window-option -g mode-keys vi

      bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v" (not "space")
      bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y" (not "enter")

      # # had to add this to get fzf/telescope to use Ctrl-j and k in tmux.
      # bind-key -n C-j send-keys Down
      # bind-key -n C-k send-keys Up

      # Restore session on tmux start (executing resurrect should already do this, but it wasn't, so this does a restore)
      # set-option -g default-command "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh; ${pkgs.zsh}/bin/zsh"
      set-hook -g after-new-session 'run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh'

      # Rerun the themepack (again, this should already happen, but there were powerline formatting issues needing a refresh)
      run-shell ${themepack}/share/tmux-plugins/themepack/themepack.tmux
      
      # this code interferes with tmux-vim-navigator for tmux panes up and down, left and right work.
      # for up and down use prefix-arrow key, otherwise telescope wont respond to ctrl-j and k in nvim
      bind-key -n C-j send-keys C-j
      bind-key -n C-k send-keys C-k
    '';
  };
}
