#!/bin/bash 

# Things to customize:
# _space_id:	change command to get current space
# new_terminal:	change command to spawn new terminal

_space_id () {
	# change command here?
	#SPACE=$(/usr/local/bin/kwmc query space active id)
	SPACE=$(/usr/local/bin/chunkc tiling::query -d id)
	echo $SPACE
}

_run_wal () {
	if [[ ! -f "$1" ]]; then exit 1; fi

	wal -sn -i "$1"
}

_cache_seq () {
	SPACE=$(_space_id)

	cp ~/.cache/wal/sequences ~/.cache/wal/sequences_"$SPACE"
}

_cache_css () {
	SPACE=$(_space_id)

	cp ~/.cache/wal/colors.css ~/.cache/wal/"colors_""$SPACE"".css"
}

_cache_json() {
	SPACE=$(_space_id)

	cp ~/.cache/wal/colors.json ~/.cache/wal/"colors_""$SPACE"".json"
}

_cache() {
	_cache_seq
	_cache_css
	_cache_json
}

# TODO - add a check for sequences files that apply to destroyed desktops?
change_wallpaper () {
	FILE="$(realpath "$1")"
	if [[ ! -f "$1" ]]; then exit 1; fi

	(_run_wal "$FILE" && _cache) >/dev/null 2>&1 &
	#osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$FILE\""
	SPACE=$(_space_id)
	osascript \
    -e "tell application \"System Events\"" \
    -e "set theDesktops to a reference to every desktop" \
    -e "repeat with x from $SPACE to $SPACE" \
    -e "set picture of item x of the theDesktops to POSIX file \"$FILE\"" \
    -e "end repeat" \
    -e "end tell"
}

new_terminal () {
	osascript -e "tell application \"iTerm2\" to create window with default profile"
}

reload_colors () {
	SPACE=$(_space_id)
	FILE=~/.cache/wal/sequences_"$SPACE"

	if [[ -f ~/.cache/wal/sequences_1 ]]
	then
		DEFAULT=~/.cache/wal/sequences_1
	else
		DEFAULT=~/.cache/wal/sequences
	fi

	if [[ -f $FILE ]]
	then
		(cat $FILE &)
	else
		(cat $DEFAULT &)
	fi
}

case "$1" in
    -w|--wallpaper)
        change_wallpaper "$2"
        ;;
    -r|--reload)
        reload_colors
        ;;
    -n|--new)
        new_terminal
        ;;
esac

