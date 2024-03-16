if status is-interactive
    # Commands to run in interactive sessions can go here

    # if set -q ZELLIJ
    # else
    #     zellij
    # end


    set fish_greeting "::<TurboFish>"

    # prompt
    starship init fish | source

    source ~/.config/fish/aliases.fish
    source ~/.config/fish/learn_cmds.fish
    zoxide init fish | source


    # SSH
    # todo: new sourced file + use an env var instead?
    keychain --eval --quiet ~/.ssh/id_ed25519 | source


    # dev
    # edgedb
    fish_add_path ~/.local/bin

    # path
    fish_add_path ~/projects/helix/target/release
end