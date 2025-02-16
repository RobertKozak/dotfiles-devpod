
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
if [ -f "/Users/robert.kozak/.config/fabric/fabric-bootstrap.inc" ]; then . "/Users/robert.kozak/.config/fabric/fabric-bootstrap.inc"; fi
. "$HOME/.atuin/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/robertkozak/.cache/lm-studio/bin"
