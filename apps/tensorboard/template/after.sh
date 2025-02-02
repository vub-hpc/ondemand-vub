# wait for the Tensorboard server to start
echo "$(date): waiting for TensorBoard server to open port ${port}..."

if wait_until_port_used "${host}:${port}" 300; then
  echo "$(date): discovered TensorBoard server listening on port ${port}!"

else
  echo "$(date): timed out waiting for TensorBoard server to open port ${port}!"
  echo "- wait ended at: $(date)"
  pkill -P ${SCRIPT_PID}
  clean_up 1
fi

sleep 2
