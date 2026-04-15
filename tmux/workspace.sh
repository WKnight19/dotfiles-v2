#!/usr/bin/env bash

PROJECTS="$HOME/dev"

selected=$(ls -d "$DEV_DIR"/*/ | fzf)

[ -z "$selected" ] && exit 0

session=$(basename "$selected")

# If session doesn't exist, create it
if ! tmux has-session -t "$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -c "$selected"

  # Window 1: editor
  tmux rename-window -t "$session:1" "editor"
  tmux send-keys -t "$session:editor" "nvim" C-m

  # Window 2: shell/server
  tmux new-window -t "$session" -n "server" -c "$selected"

  # Window 3: git/logs
  tmux new-window -t "$session" -n "git" -c "$selected"
  tmux send-keys -t "$session:git" "git status" C-m
fi

tmux attach -t "$session"
