#!/bin/bash

if [[ $(which kubectl) && -n $KUBECONFIG ]]; then
  CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null)

  if [[ -n $CURRENT_CONTEXT ]]; then
    namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
    [[ -n $namespace ]] && namespace=" | $namespace"

    FG_COLOR="#[fg=#{@thm_bg}]"
    # Define @thm colors based on environment
    case "$CURRENT_CONTEXT" in
    *dev*)
      BG_COLOR="#[bg=#{@thm_green}]"
      ;; # Green for dev
    *tst*)
      BG_COLOR="#[bg=#{@thm_yellow}]"
      ;; # Yellow for test
    *stg*)
      BG_COLOR="#[bg=#{@thm_yellow}]"
      ;; # Yellow for stage
    *prd*)
      BG_COLOR="#[bg=#{@thm_red}]"
      ;;                                       # Red for prod
    *) BG_COLOR="#[fg=white,bg=#{@thm_bg}]" ;; # Default style
    esac

    echo -n "${FG_COLOR}${BG_COLOR}#[reverse]#[noreverse]${FG_COLOR} $CURRENT_CONTEXT$namespace #[reverse]#[none]"
  fi
fi
