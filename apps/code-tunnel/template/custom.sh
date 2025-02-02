#!/bin/bash

if [[ "$OOD_CONTEXT_CLEANUP_LOGIN" -eq 1 ]]; then
    tokfn=~/.vscode/cli/token.json
    echo "Cleaning up local token file $fn"
    rm -f "$tokfn"
fi

# Merge custom confi with bundled config
confdir=$(dirname "$TCONF_BUNDLE")

export TCONF="$confdir/custom_final.conf"

custom="$confdir/custom.conf"
cat > $custom<<EOF
new-session -d -s $TSES
set -g status off #NOTE: this will disable the status bar (green text in the bottom)
EOF

IFS=$'\n' # set the Internal Field Separator to newline
for line in $(cat "$confdir/custom_commands.conf"); do
    if [ "$line" == "reset" ]; then
        export TMUX_WAITFOR=CUSTOMCHANNEL
        # must release the lock from within, so must be run as command in shell
        # so not : echo "wait-for -S $TMUX_WAITFOR" >> $custom
        echo "send-keys -t $TSES \"tmux -S $TSOCK wait-for -S $TMUX_WAITFOR\" C-m" >> $custom
    fi
    cmd=$(echo "$line" | sed 's/"/\\\"/g')
    echo "send-keys -t $TSES \"$cmd\" C-m" >> $custom
done

cat "$TCONF_BUNDLE" "$custom" > "$TCONF"
