alias cat bat
alias cd z
alias ls exa
alias lg lazygit
alias zl zellij
alias c wl-copy
alias t task

function tl
    set -l cmd "task list $argv"
    set cmd (string replace -r '@' 'project:' -- $cmd)
    eval $cmd
end

function ta
    command task add $argv
end

function h
    if set -q argv[1]
        command hx $argv
    else
        command hx . $argv
    end
end

function code
    command code --ozone-platform=wayland $argv
end
