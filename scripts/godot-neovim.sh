#!/usr/bin/env bash

# Script provided by Mathijs Bakker's godotdev.nvim, licensed under the Apache
# License Version 2.0.
#
# A copy of the original script can be found at
# https://github.com/Mathijs-Bakker/godotdev.nvim/blob/79d9315988b7772c03a1cabb6f31f5287c849e2b/doc/neovim-external-editor-setup.md#installation
#
# A copy of the original license can be found at
# https://github.com/Mathijs-Bakker/godotdev.nvim/blob/79d9315988b7772c03a1cabb6f31f5287c849e2b/LICENSE

# Godot → Neovim launcher with GUI terminal focus
# Usage:
#   godot-nvr.sh [terminal_name] +{line} {file} [--tab|--vsplit]

# -----------------------------
# Arguments
# -----------------------------
DEFAULT_TERMINAL="${DEFAULT_TERMINAL:=ghostty}"
ARG0="$1"

if [[ "$ARG0" == +* || "$ARG0" == --* || -f "$ARG0" ]]; then
   # No terminal argument provided, use default
   GODOT_TERMINAL="$DEFAULT_TERMINAL"
else
   # First argument is terminal name
   GODOT_TERMINAL="$ARG0"
   shift
fi

SOCKET="${SOCKET:=/tmp/godot.nvim}" # Neovim socket path

OPEN_MODE="window"
LINE=""
FILE=""

# -----------------------------
# Parse remaining arguments
# -----------------------------
while [[ $# -gt 0 ]]; do
   case "$1" in
   --tab)
      OPEN_MODE="tab"
      shift
      ;;
   --vsplit)
      OPEN_MODE="vsplit"
      shift
      ;;
   +[0-9]*)
      LINE="${1#+}"
      shift
      ;;
   *)
      FILE="$1"
      shift
      ;;
   esac
done

[ "$FILE" = "" ] && exit 0

# -----------------------------
# Open file in Neovim or jump to buffer
# -----------------------------
if nvr --servername "$SOCKET" --remote-expr \
   "bufexists(fnamemodify('$FILE', ':p'))" | grep -q 1; then
   CMD=":buffer $(basename "$FILE")"
else
   case "$OPEN_MODE" in
   window) CMD=":e $FILE" ;;
   tab) CMD=":tabedit $FILE" ;;
   vsplit) CMD=":vsplit $FILE" ;;
   esac
fi

[ "$LINE" != "" ] && CMD="$CMD | call cursor($LINE,1)"
CMD="$CMD | normal! zz"

nvr --servername "$SOCKET" --remote-send "<C-\\><C-N>${CMD}<CR>"

# -----------------------------
# Focus GUI terminal (Hyprland)
# -----------------------------
hyprctl dispatch focuswindow "class:$GODOT_TERMINAL"
