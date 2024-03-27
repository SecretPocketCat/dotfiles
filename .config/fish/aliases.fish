alias cat bat
alias cd z
alias ls exa
alias lg lazygit
alias t task

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
