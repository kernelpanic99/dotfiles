function t --description 'Open or attach a tmux session for a directory (nvim + shell split)'
    if set -q argv[1]
        set dir (realpath $argv[1])
    else
        set dir $PWD
    end
    set session (string replace -ra '[^a-zA-Z0-9_-]' '_' (basename $dir))

    if not tmux has-session -t $session 2>/dev/null
        tmux new-session -d -s $session -c $dir
        tmux send-keys -t "$session:0.0" nvim Enter
        tmux split-window -t "$session:0" -v -c $dir
        tmux select-pane -t "$session:0.0"
    end

    if set -q TMUX
        tmux switch-client -t $session
    else
        tmux attach-session -t $session
    end
end
