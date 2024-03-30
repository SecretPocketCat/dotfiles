#!/usr/bin/fish

function wait_for_rofi_fadeout
    sleep 0.165
end

function screenshot -a cursor area
    set dir $HOME"/Pictures/screenshots/"
    set path $dir(date '+%Y-%m-%d_%H-%M-%S')".png"
    set cmd grim

    if [ -n "$cursor" ]
        set cmd $cmd " -c"
    end

    if [ -n "$area" ]
        if set selected_area $(slurp -d)
        else
            exit 0
        end

        set cmd $cmd " -g '"$selected_area"'"
    end

    # output to stdout, tee it to file and to clipboard
    set cmd $cmd ' - | tee "'$path'" | wl-copy'

    # make sure the screenshot dir exists
    mkdir -p $dir

    # wait for rofi to fade out    
    wait_for_rofi_fadeout
    # take the screenshot
    eval $cmd
    # notify about the saved file
    notify-send -t 3000 "Saved screenshot to "$path
    exit 0
end

function pick_color -a format
    wait_for_rofi_fadeout
    hyprpicker --no-fancy -f $format --autocopy
end

if set selected (echo "󰩬 Area|󰩬 Area (no )|󰍹 Screen|󰍹 Screen (no )|󰈊 Pick color [#hex]|󰈊 Pick color [R G B]|󰈊 Pick color rgb(R, G, B)" | rofi -format 'd' -sep '|' -dmenu -i)
    echo $selected
    switch "$selected"
        case 1
            screenshot "" 1
        case 2
            screenshot 1 1
        case 3
            screenshot
        case 4
            screenshot 1
        case 5
            pick_color hex
        case 6
            pick_color rgb
        case 7
            pick_color rgb | sd '(\w+)\s+(\w+)\s+(\w+)' 'rgb($1, $2, $3)' | wl-copy
    end
end
