time1=$(date +%s)

<%= ERB.new(File.read('../common_files/wait_server_start.sh.erb'), eoutvar: 'child').result(binding) %>

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

if wait_until_tb_ready "$OOD_SESSION_STAGED_ROOT/tensorboard.log" $(( ${MAXWAIT:-180} - time2 + time1 )); then
    echo "$(date): TensorBoard server ready!"
else
    echo "$(date): timed out waiting for TensorBoard server to get ready!"
    echo "- wait ended at: $(date)"
    pkill -P ${SCRIPT_PID}
    clean_up 1
fi
