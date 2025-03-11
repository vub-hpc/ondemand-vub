# wait for the Tensorboard server to start
echo "$(date): waiting for TensorBoard server to open port ${port}..."
time1=$(date +%s)

if wait_until_port_used "${host}:${port}" $MAXWAIT; then
    echo "$(date): discovered TensorBoard server listening on port ${port}!"

else
    echo "$(date): timed out waiting for TensorBoard server to open port ${port}!"
    echo "- wait ended at: $(date)"
    pkill -P ${SCRIPT_PID}
    clean_up 1
fi

sleep 2

function wait_until_tb_ready () {
    logfile=$1
    maxwait=$2
    while ((maxwait-- > 0)); do
        grep -q "^Serving TensorBoard" "$logfile" && return
        sleep 1
    done
    return 1
}

echo "$(date): waiting for TensorBoard server to get ready..."
time2=$(date +%s)

if wait_until_tb_ready "$OOD_SESSION_STAGED_ROOT/tensorboard.log" $(( MAXWAIT - time2 + time1 )); then
    echo "$(date): TensorBoard server ready!"

else
    echo "$(date): timed out waiting for TensorBoard server to get ready!"
    echo "- wait ended at: $(date)"
    pkill -P ${SCRIPT_PID}
    clean_up 1
fi
