#!/usr/bin/env fish

function find_and_set_workspace
    set name $argv[1]
    set path $argv[2]

    set git_repos (find $path -name .git -exec dirname {} \; -prune)
    set -l pairs
    for repo in $git_repos
        set -a pairs (printf "%s:%s" (string split "/" $repo)[-1] $repo)
    end

    echo $git_repos
    echo (string join ";" $pairs)
    set -Ux "WORKSPACE_$name" (string join ";" $pairs)
end

find_and_set_workspace work ~/work
find_and_set_workspace gamedev ~/gamedev
