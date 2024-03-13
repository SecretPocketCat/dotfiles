#!/usr/bin/fish

if [ $argv[1] ]
    # switch focus
    hyprctl dispatch focuswindow address:$ROFI_INFO >/dev/null &
else
    # parse valid windows into options for rofi
    hyprctl clients -j | jq -r '.[] | select(.pid != -1) | "  \(.class | clampString(20))  \(.title)\u0000info\u001f\(.address)\u001ficon\u001f\(.class | ascii_downcase)"'
end
