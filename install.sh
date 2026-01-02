#!/bin/bash
set -eu

SCRIPT_DIR=$(cd $(dirname $0); pwd)

if [ ! -f ~/.git-prompt.sh ]; then
  echo "==== install git-prompt.sh ==="
  URL="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
  curl ${URL} -o ~/.git-prompt.sh
  echo "==== finish install git-prompt.sh ==="
fi

git config --global include.path '~/config/gitconfig'

if [ ! -d ~/.config/nvim ]; then
  echo "=== create nvim config directory ==="
  mkdir -p ~/.config/nvim
  echo "=== finish create nvim config directory ==="
fi

echo "=== create symlinks ==="
ln -nfs "${SCRIPT_DIR}/_vimrc" ~/.config/nvim/init.vim
ln -nfs "${SCRIPT_DIR}/_zshrc" ~/.zshrc
ln -nfs "${SCRIPT_DIR}/tmux.conf" ~/.tmux.conf
ln -nfs "${SCRIPT_DIR}/starship.toml" ~/.config/
ln -nfs "${SCRIPT_DIR}/wezterm" ~/.config/
echo "=== finish create symlinks ==="
