# vim:ft=sh et ts=4 sw=4

function cdreal() {
    cd `readlink -f $1`
}

if [[ -f ~/.bash_aliases.secure ]]; then
    . ~/.bash_aliases.secure
fi

if [[ -f ~/.bash_aliases.local ]]; then
    . ~/.bash_aliases.local
fi

