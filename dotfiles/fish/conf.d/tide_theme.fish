# Tide theme matching gruvbubble zsh theme
# Layout: character only on left, pwd + git + status on right
set -U tide_left_prompt_items character
set -U tide_right_prompt_items pwd git status

# Prompt character (U+F120 = nerd fonts prompt glyph)
set -U tide_character_icon "  "
set -U tide_character_color 87af00 # color 106 - prompt_symbol_color
set -U tide_character_color_failure af0000 # color 124 - prompt_symbol_error_color

# PWD bubble (color 66 = filepath_color, color 236 = bubble_color bg)
set -U tide_pwd_bg_color black # color 236
set -U tide_pwd_color white # color 66

# Git bubble
set -U tide_git_bg_color 87af00 # color 106 - clean
set -U tide_git_bg_color_unstable d78700 # color 172 - unstaged
set -U tide_git_bg_color_urgent af5f87 # color 132 - unmerged
set -U tide_git_color_branch 303030 # color 236 - dark text on colored bg
set -U tide_git_color_dirty 303030
set -U tide_git_color_staged 303030
set -U tide_git_color_untracked 303030
set -U tide_git_color_conflicted 303030
set -U tide_git_color_stash 949494 # color 246
set -U tide_git_color_upstream 303030
set -U tide_git_color_operation 303030

# Status bubble
set -U tide_status_bg_color 303030 # color 236
set -U tide_status_bg_color_failure 303030
set -U tide_status_color 87af00 # color 106
set -U tide_status_color_failure af0000 # color 124
