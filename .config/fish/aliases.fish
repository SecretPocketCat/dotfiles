alias cat bat
alias cd z
alias ls exa
alias lg lazygit
alias t task
alias zel zellij
alias c wl-copy

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
