# vim:ft=sh et ts=4 sw=4

function cdreal() {
    cd `readlink -f $1`
}

if [[ -x ~/git-prompt/git-prompt.sh ]]; then
    . ~/git-prompt/git-prompt.sh
fi
