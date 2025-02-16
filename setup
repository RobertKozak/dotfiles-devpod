#!/bin/bash

apt update
apt upgrade -y
apt install -y git curl fzf stow tmux neovim starship

mkdir -p $HOME/.config/

cp -r nvim/ $HOME/.config/nvim
cp -r tmux/ $HOME/.config/tmux
cp -r direnv/ $HOME/.config/direnv

cp .* $HOME/
