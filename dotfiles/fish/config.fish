# ~ / .config / fish / config.fish

# 1. Environment Variables
set -gx STOW_DIR "$HOME/.dotfiles/"
set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
set -gx EDITOR nvim
set -gx QT_QPA_PLATFORMTHEME qt6ct
set -gx OPENCODE_ENABLE_EXA 1

# World of Warcraft Paths
set -gx WOW_DIR "$HOME/Games/Heroic/Prefixes/default/Battle.net/pfx/drive_c/Program Files (x86)/World of Warcraft/_retail_/WTF"
set -gx WOW_CLASSIC_DIR "$HOME/Games/Heroic/Prefixes/default/Battle.net/pfx/drive_c/Program Files (x86)/World of Warcraft/_classic_era_/WTF"

# Path additions
fish_add_path "$HOME/.luarocks/bin"
fish_add_path "$HOME/bin"
fish_add_path "$HOME/.spicetify"

# 2. Source .env if it exists
if test -f ~/.env
    # Fish doesn't 'source' bash-style .env files natively. 
    # Use a plugin like 'bass' or 'posix-source' if they are complex.
    # For simple KEY=VALUE, you can use:
    for line in (cat ~/.env | grep -v '^#')
        set -gx (echo $line | cut -d = -f 1) (echo $line | cut -d = -f 2-)
    end
end

# 3. Tmux Auto-start (Converted from your .zshrc)
# Logic: If tmux exists and we aren't already inside it, attach to 'default' or create it [cite: 31, 32, 33]
if status is-interactive
    if command -v tmux >/dev/null; and test -z "$TMUX"
        tmux attach -t default; or tmux new -s default
        exit
    end
end

# 4. Aliases
alias vim="nvim"
alias homestow="stow -t ~"
alias la="ls -lah"

# 5. Initialize Starship
starship init fish | source
# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # smth smth
end
