export PATH=${HOME}/.local/bin:${HOME}/.local/npm/bin:${HOME}/.cargo/bin:${PATH}

#export VISUAL=lvim
export VISUAL=hx
export EDITOR="$VISUAL"
export DELTA_PAGER="delta-pager"

prompt() {
	local -r PROMPT_MODULES="jobs,exit,cwd,git"
	PS1="$($HOME/.local/bin/powerline-go -modules "${PROMPT_MODULES}" -newline --numeric-exit-codes -error $? -jobs $({ jobs -p -r; jobs -p -s; } | wc -l))"
}
if [ "$TERM" != "linux" ] && [ -f "$HOME/.local/bin/powerline-go" ]
then
	PROMPT_COMMAND=prompt
fi

#disable Ctrl+D for the first time after every command
IGNOREEOF=1

alias e="$VISUAL"
alias g="git"
alias lg="lazygit"
alias ls="exa"
alias ll="exa -l"
alias cdgr='cd $(git rev-parse --show-toplevel || echo '.')'
alias u="cd .."
alias uu="cd ../.."
alias uuu="cd ../../.."
alias uuuu="cd ../../../.."
alias uuuuu="cd ../../../../.."

alias git-prune-merged="git branch --merged | grep -vP '^\*|^\*? master$' | xargs -r git branch -d"

# Yocto
function ycb() {
    bitbake -c cleansstate "$1" && bitbake "$@"
}

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash

if which zoxide
then
	eval "$(zoxide init bash --cmd cd --hook pwd)"
fi
