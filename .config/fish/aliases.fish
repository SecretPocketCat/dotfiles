alias cat bat
alias cd z
alias ls exa
alias lg lazygit

function t
    command task $argv
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
