if status is-interactive
    # Commands to run in interactive sessions can go here

    # autostart zellij
    # if not set -q VSCODE_TERM
    #     eval (zellij setup --generate-auto-start fish | string collect)
    # end

    set fish_greeting "::<TurboFish>"

    # prompt
    zoxide init fish | source

    # aliases - add only after sourcing other stuff
    source ~/.config/fish/aliases.fish

    # SSH
    # todo: new sourced file + use an env var instead?
    keychain --eval --quiet ~/.ssh/id_ed25519 | source


    direnv hook fish | source

    # path
    # scripts
    fish_add_path ~/scripts
    # hx
    fish_add_path ~/projects/helix/target/release
    # dev
    # edgedb
    fish_add_path ~/.local/bin
end
