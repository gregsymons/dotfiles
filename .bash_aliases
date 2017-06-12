# vim:ft=sh et ts=4 sw=4

function cdreal() {
    cd `readlink -f $1`
}

if [[ -f ~/git-prompt/git-prompt.sh ]]; then
    . ~/git-prompt/git-prompt.sh
fi

if [ -f /usr/local/share/gitprompt.sh ]; then
GIT_PROMPT_THEME=Default
GIT_PROMPT_ONLY_IN_REPO=1
. /usr/local/share/gitprompt.sh
fi

if [[ -f ~/.bash_aliases.secure ]]; then
    . ~/.bash_aliases.secure
fi

if [[ -f ~/.bash_aliases.local ]]; then
    . ~/.bash_aliases.local
fi

