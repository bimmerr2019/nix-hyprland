{
  pkgs,
  lib,
  username,
  host,
  config,
  ...
}:

let
  inherit (import ../hosts/${host}/variables.nix)
    browser
    terminal
    extraMonitorSettings
    keyboardLayout
    ;
in
with lib;
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    extraConfig =
      let
        modifier = "SUPER";
      in
      concatStrings [
        ''
          env = NIXOS_OZONE_WL, 1
          env = NIXPKGS_ALLOW_UNFREE, 1
          env = XDG_CURRENT_DESKTOP, Hyprland
          env = XDG_SESSION_TYPE, wayland
          env = XDG_SESSION_DESKTOP, Hyprland
          env = GDK_BACKEND, wayland, x11
          env = CLUTTER_BACKEND, wayland
          env = QT_QPA_PLATFORM,wayland;xcb
          env = QT_QPA_PLATFORMTHEME,qt5ct
          env = QT_WAYLAND_DISABLE_WINDOWDECORATION, 1
          env = QT_AUTO_SCREEN_SCALE_FACTOR, 1
          env = SDL_VIDEODRIVER, x11
          env = MOZ_ENABLE_WAYLAND, 1
          exec-once = dbus-update-activation-environment --systemd --all
          exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORM
          exec-once = pkill swww || true; swww init && swww img /home/${username}/Pictures/Wallpapers/0169.jpg
          exec-once = pkill waybar || true; waybar
          exec-once = pkill swaync || true; swaync
          exec-once = pkill nm-applet || true; nm-applet --indicator
          exec-once = pkill lxqt-policykit-agent || true; lxqt-policykit-agent
          exec-once = pkill pypr || true; pypr
          # exec-once = restart-nextcloud-client.sh &
          exec-once=[workspace 1 silent] kitty tmux
          exec-once=[workspace 2 silent] qutebrowser
          exec-once=[workspace 3 silent] ${pkgs.appimage-run}/bin/appimage-run /opt/appimages/simplex-desktop-x86_64.AppImage
          exec-once=[workspace 4 silent] ${pkgs.appimage-run}/bin/appimage-run /opt/appimages/session-desktop-linux-x86_64-1.14.2.AppImage
          monitor=,preferred,auto,1
          ${extraMonitorSettings}
          general {
            gaps_in = 6
            gaps_out = 8
            border_size = 2
            layout = dwindle
            resize_on_border = true
            col.active_border = rgb(${config.stylix.base16Scheme.base08}) rgb(${config.stylix.base16Scheme.base0C}) 45deg
            col.inactive_border = rgb(${config.stylix.base16Scheme.base01})
          }
          input {
            kb_layout = ${keyboardLayout}
            kb_variant =
            kb_model =
            kb_options =
          #  kb_options = caps:ctrl_modifier
            kb_options=ctrl:nocaps
            kb_rules =
            repeat_rate = 50
            repeat_delay = 300
            numlock_by_default = true
            left_handed = false
            follow_mouse = true
            float_switch_override_focus = false
            touchpad {
              disable_while_typing = true
              natural_scroll = true
              clickfinger_behavior = false
              middle_button_emulation = true
              tap-to-click = true
              drag_lock = false
            }
            sensitivity = 2 # -1.0 - 1.0, 0 means no modification.
            # accel_profile = flat
          }
          windowrule = noborder,^(wofi)$
          windowrule = center,^(wofi)$
          windowrule = tile, ^(.*.AppImage)$
          windowrule = float, nm-connection-editor|blueman-manager
          windowrule = float, swayimg|vlc|Viewnior|pavucontrol
          windowrule = float, nwg-look|qt5ct
          windowrule = float, zoom
          windowrule = float,^(floating_fzf)$
          windowrule = center,^(floating_fzf)$
          windowrulev2 = opacity 0.9 0.7, class:^(floorp)$
          windowrulev2 = workspace 2, class:^(qutebrowser)$
          windowrulev2 = workspace 3, class:^(floorp)$
          windowrulev2 = workspace 4, class:^(Session)$
          windowrulev2 = workspace 5, class:^(mpv)$
          windowrulev2 = workspace 6, class:^(org.keepassxc.KeePassXC)$
          windowrulev2 = workspace 7, class:^(QTodoTxt2)$
          windowrulev2 = workspace 8, class:^(org.pwmt.zathura)$
          gestures {
            workspace_swipe = true
            workspace_swipe_fingers = 3
          }
          misc {
            initial_workspace_tracking = 0
            mouse_move_enables_dpms = true
            key_press_enables_dpms = false
          }
          animations {
            enabled = yes
            bezier = wind, 0.05, 0.9, 0.1, 1.05
            bezier = winIn, 0.1, 1.1, 0.1, 1.1
            bezier = winOut, 0.3, -0.3, 0, 1
            bezier = liner, 1, 1, 1, 1
            animation = windows, 1, 6, wind, slide
            animation = windowsIn, 1, 6, winIn, slide
            animation = windowsOut, 1, 5, winOut, slide
            animation = windowsMove, 1, 5, wind, slide
            animation = border, 1, 1, liner
            animation = fade, 1, 10, default
            animation = workspaces, 1, 5, wind
          }
          decoration {
            rounding = 10
            # drop_shadow = true
            # shadow_range = 4
            # shadow_render_power = 3
            # col.shadow = rgba(1a1a1aee)
            blur {
                enabled = true
                size = 5
                passes = 3
                new_optimizations = on
                ignore_opacity = off
            }
          }
          plugin {
            hyprtrails {
            }
          }
          dwindle {
            pseudotile = true
            preserve_split = true
          }
          bind = ${modifier},Return,exec,${terminal}
          bind = ${modifier},H,exec,list-hypr-bindings
          bind = ${modifier}SHIFT,code:61,exec,list-hypr-bindings    #'?'
          bind = ${modifier},D,exec,rofi-launcher
          bind = ${modifier}SHIFT,Return,exec,alacritty
          bind = ${modifier},Y,exec,pypr toggle yazi
          bind = ${modifier},M,exec,pypr toggle movies
          bind = ${modifier},B,exec,pypr toggle books
          bind = ${modifier},L,exec,pypr toggle llm
          bind = ${modifier},E,exec,pypr toggle mutt
          bind = ${modifier},N,exec,pypr toggle newsboat
          bind = ${modifier}ALT,W,exec,wallsetter
          bind = ${modifier},Q,killactive,
          bind = ${modifier},W,exec,web-search
          bind = ${modifier}SHIFT,N,exec,swaync-client -rs
          bind = ${modifier}SHIFT,W,exec,${browser}
          bind = ${modifier}SHIFT,E,exec,emopicker9000
          bind = ${modifier},S,exec,screenshootin area
          bind = ,Print,exec,screenshootin full
          bind = ${modifier},P,pseudo,
          bind = ${modifier}SHIFT,I,togglesplit,
          bind = ${modifier},F,fullscreen,
          bind = ${modifier}SHIFT,F,togglefloating,
          bind = ${modifier}SHIFT,C,exit,
          bind = ${modifier}ALT,R,exec,pkill waybar; waybar
          bind = ${modifier},C,exec,hyprpicker -a
          bind = ${modifier},left,movefocus,l
          bind = ${modifier},right,movefocus,r
          bind = ${modifier},up,movefocus,u
          bind = ${modifier},down,movefocus,d
          bind = ${modifier}SHIFT,left,movewindow,l
          bind = ${modifier}SHIFT,right,movewindow,r
          bind = ${modifier}SHIFT,up,movewindow,u
          bind = ${modifier}SHIFT,down,movewindow,d
          bind = ${modifier},h,movefocus,l
          bind = ${modifier},l,movefocus,r
          bind = ${modifier},k,movefocus,u
          bind = ${modifier},j,movefocus,d
          bind = ${modifier}SHIFT,h,movewindow,l
          bind = ${modifier}SHIFT,l,movewindow,r
          bind = ${modifier}SHIFT,k,movewindow,u
          bind = ${modifier}SHIFT,j,movewindow,d
          bind = ${modifier},SPACE,togglespecialworkspace
          bind = ${modifier}SHIFT,SPACE,movetoworkspace,special
          bind = ${modifier},1,workspace,1
          bind = ${modifier},2,workspace,2
          bind = ${modifier},3,workspace,3
          bind = ${modifier},4,workspace,4
          bind = ${modifier},5,workspace,5
          bind = ${modifier},6,workspace,6
          bind = ${modifier},7,workspace,7
          bind = ${modifier},8,workspace,8
          bind = ${modifier},9,workspace,9
          bind = ${modifier},0,workspace,10
          bind = ${modifier}SHIFT,1,movetoworkspace,1
          bind = ${modifier}SHIFT,2,movetoworkspace,2
          bind = ${modifier}SHIFT,3,movetoworkspace,3
          bind = ${modifier}SHIFT,4,movetoworkspace,4
          bind = ${modifier}SHIFT,5,movetoworkspace,5
          bind = ${modifier}SHIFT,6,movetoworkspace,6
          bind = ${modifier}SHIFT,7,movetoworkspace,7
          bind = ${modifier}SHIFT,8,movetoworkspace,8
          bind = ${modifier}SHIFT,9,movetoworkspace,9
          bind = ${modifier}SHIFT,0,movetoworkspace,10
          bindm = ${modifier},mouse:272,movewindow   # left mouse button
          bindm = ${modifier},mouse:273,resizewindow   # right mouse button
          bind = ALT,Tab,cyclenext
          bind = ALT,Tab,bringactivetotop
          bind = ${modifier}CONTROL,right,workspace,e+1
          bind = ${modifier}CONTROL,left,workspace,e-1
          bind = ${modifier},mouse_down,workspace, e+1
          bind = ${modifier},mouse_up,workspace, e-1
          bind = ,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
          bind = ,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
          binde = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
          bind = ,XF86AudioPlay, exec, playerctl play-pause
          bind = ,XF86AudioPause, exec, playerctl play-pause
          bind = ,XF86AudioNext, exec, playerctl next
          bind = ,XF86AudioPrev, exec, playerctl previous
          bind = ,XF86MonBrightnessDown,exec,brightnessctl set 5%-
          bind = ,XF86MonBrightnessUp,exec,brightnessctl set +5%
        ''
      ];
  };
}
