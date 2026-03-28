#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
eval "$(zoxide init bash)"

# Создать новый alias: a <имя> <команда>
a() {
    [[ $# -lt 2 ]] && echo "usage: a <name> <command>" && return 1
    local name="$1"; shift
    local cmd="$*"
    alias "$name=$cmd"
    echo "alias $name='$cmd'" >> ~/.bashrc
    echo "alias $name='$cmd'"
}
#eval "$(starship init bash)"
alias cc='claude --dangerously-skip-permissions'
alias pc='pacman -S'
alias tt='~/.config/kitty/toggle-theme.sh'
