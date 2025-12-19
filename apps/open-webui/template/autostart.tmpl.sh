ollama_port=11434
webui_port=8080
server_name="ollama"
server_image="/apps/brussel/containers/$server_name/web-api.sif"

module load "$MODULES_TO_LOAD"
mkdir -p $OPEN_WEBUI_DATA

unshare -rn bash -eu <<EOF
ip link set lo up

export WEBUI_SECRET_KEY=$(head -c 12 /dev/random | base64)

echo 'ollama models dir at $OLLAMA_MODELS'
echo 'Starting ollama...'
export OLLAMA_HOST=0.0.0.0:$ollama_port
export OLLAMA_MODELS="$OLLAMA_MODELS"
export OLLAMA_NOPRUNE="true"
ollama serve &>> "$OOD_SESSION_STAGED_ROOT/ollama-server.log" &
ollama_pid=\$!

echo 'Open WebUI data dir at $OPEN_WEBUI_DATA'
echo 'Starting Open WebUI...'
apptainer run \
  --env WEBUI_AUTH=False \
  --env ENABLE_OPENAI_API=False \
  --env ENABLE_DIRECT_CONNECTIONS=False \
  --env OFFLINE_MODE=True \
  --env HF_HUB_OFFLINE=1 \
  --env ENABLE_WEB_SEARCH=False \
  --env OLLAMA_BASE_URL=http://127.0.0.1:$ollama_port \
  --env WEBUI_SECRET_KEY=$WEBUI_SECRET_KEY \
  --bind $OPEN_WEBUI_DATA:/app/backend/data \
  $server_image  bash /app/backend/start.sh &>> "$OOD_SESSION_STAGED_ROOT/open-webui.log" &
webui_pid=\$!

echo "Waiting for Open WebUI to start..."
until curl --output /dev/null --silent --head --fail http://localhost:$webui_port; do
    printf '.'
    sleep 1
done
echo "Open WebUI is up."

# Create new firefox profile and start new isolated instance with that profile
firefox -CreateProfile "$SLURM_JOB_ID /tmp/ff-profile-$SLURM_JOB_ID"
firefox -no-remote -P "$SLURM_JOB_ID" --kiosk http://127.0.0.1:$webui_port

[[ -n \$ollama_pid ]] && env kill --verbose \$ollama_pid
[[ -n \$webui_pid ]] && env kill --verbose \$webui_pid

EOF
