#!/usr/bin/fish

set workspace_id (hyprctl activeworkspace -j | jq ".id")
set current_ff_cmd 'hyprctl clients -j | jq ".[] | select(.initialClass == \"firefox\" and .workspace.id == "'$workspace_id'") | .address"'
set current_ff_address (eval $current_ff_cmd)

set url $argv[1]

if [ -z "$url" ]
    echo "No URL" >&2
    exit 1
end

if [ -n "$current_ff_address" ]
    # remove quotes
    set current_ff_address (string replace -a '"' '' $current_ff_address)

    # focus the current instance of FF to open the tab there
    hyprctl dispatch focuswindow address:$current_ff_address
    # sleep 0.3
    firefox --new-tab $url &
else
    firefox --new-window $url &
end
