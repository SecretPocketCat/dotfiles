#!/usr/bin/fish

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
    sleep 0.165
    # take the screenshot
    eval $cmd
    # notify about the saved file
    notify-send -t 3000 "Saved screenshot to "$path
    exit 0
end

if set selected (echo "󰩬 Area|󰩬 Area (no )|󰍹 Screen|󰍹 Screen (no )" | rofi -format 'd' -sep '|' -dmenu -i)
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
    end
end
