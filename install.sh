#!/bin/bash

export XDG_CONFIG_HOME="$HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

# Create symlinks for existing configurations
ln -sf "$PWD/nvim" "$XDG_CONFIG_HOME"/nvim
ln -sf "$PWD/tmux" "$XDG_CONFIG_HOME"/tmux
ln -sf "$PWD/direnv" "$XDG_CONFIG_HOME"/direnv
ln -sf "$PWD/.tmux.conf" "$HOME"/.tmux.conf

cp .* "$HOME/"
