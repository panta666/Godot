#!/bin/sh
printf '\033c\033]0;%s\a' HSD Godot Projekt
base_path="$(dirname "$(realpath "$0")")"
"$base_path/BattleForBachelor.x86_64" "$@"
