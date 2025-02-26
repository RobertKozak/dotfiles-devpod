# System-wide .bashrc file for interactive bash(1) shells.
if [ -z "$PS1" ]; then
   return
fi

PS1='\h:\W \u\$ '
# Make bash check its window size after a process completes
shopt -s checkwinsize

[ -r "/etc/bashrc_$TERM_PROGRAM" ] && . "/etc/bashrc_$TERM_PROGRAM"
if [ -f "/Users/robert.kozak/.config/fabric/fabric-bootstrap.inc" ]; then . "/Users/robert.kozak/.config/fabric/fabric-bootstrap.inc"; fi
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/robertkozak/.cache/lm-studio/bin"
