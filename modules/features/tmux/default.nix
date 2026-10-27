{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.tmux = inputs.wrappers.wrappers.tmux.wrap {
      inherit pkgs;

      # Base settings
      sourceSensible = true;
      prefix = "C-a";
      terminal = "st-256color";
      escapeTime = 0;
      baseIndex = 1;
      paneBaseIndex = 0; # module default is 1, your config never set it
      mouse = true;
      modeKeys = "vi";
      statusKeys = "vi"; # tmux derives this from $EDITOR when mode-keys is vi
      allowPassthrough = true;
      visualActivity = false;

      # Keep the values tmux-sensible would have given you; the module
      # sets these after sensible, so its defaults would otherwise win
      historyLimit = 50000;
      aggressiveResize = true;

      # Keep tmux's default kill-window/kill-pane confirmation
      disableConfirmationPrompt = false;

      # You bind y to wl-copy yourself, so don't use the built-in vi keys
      vimVisualKeys = false;

      setEnvironment = {
        SSH_AUTH_SOCK = "$HOME/.ssh/ssh_auth_sock";
      };

      # wl-copy for copy-mode; tmux-yank also uses it
      runtimePkgs = [pkgs.wl-clipboard];

      configBefore = ''
        set-option -sa terminal-features ',st-256color:RGB'
        set-option -g focus-events on
        set-option -g detach-on-destroy off

        # Vim-like visual mode and keys
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'

        # Vim-like pane switching
        bind -r ^ last-window
        bind -r k select-pane -U
        bind -r j select-pane -D
        bind -r h select-pane -L
        bind -r l select-pane -R

        bind -r q kill-session

        # create window/split in pwd
        bind  c  new-window      -c "#{pane_current_path}"
        bind  %  split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"

        # Sessionizer
        # bind-key -r f run-shell "tmux neww ~/.local/scripts/tmux-sessionizer"
        # bind-key -r i run-shell "tmux neww ~/.local/scripts/tmux-cht.sh"

        # bind-key -r S run-shell "~/.local/scripts/tmux-sessionizer ~/Projects/python/"
        # bind-key -r C run-shell "~/.local/scripts/tmux-sessionizer ~/Projects/c/"
        # bind-key -r G run-shell "~/.local/scripts/tmux-sessionizer ~/Projects/go"
        # bind-key -r R run-shell "~/.local/scripts/tmux-sessionizer ~/Projects/rust"
        # bind-key -r P run-shell "~/.local/scripts/tmux-sessionizer ~/Projects/"
      '';

      plugins = [
        {
          plugin = pkgs.tmuxPlugins.catppuccin;
          name = "catppuccin";
          configBefore = ''
            set -g @catppuccin_flavor "mocha"
            set -g @catppuccin_date_time_text " %H:%M"
          '';
          # catppuccin v2 builds status modules after it is sourced
          configAfter = ''
            set -g status-left-length 100
            set -g status-left "#{E:@catppuccin_status_session}"
            set -g status-right "#{E:@catppuccin_status_date_time}"
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.yank;
          name = "yank";
        }
        {
          plugin = pkgs.tmuxPlugins.copycat;
          name = "copycat";
        }
        {
          plugin = pkgs.tmuxPlugins.resurrect;
          name = "resurrect";
        }
        {
          plugin = pkgs.tmuxPlugins.continuum;
          name = "continuum";
          # continuum hooks into status-right, so it must load after
          # catppuccin has finished setting it, and after resurrect
          after = [
            "catppuccin"
            "resurrect"
          ];
          configBefore = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '10'
          '';
        }
      ];
    };
  };
}
