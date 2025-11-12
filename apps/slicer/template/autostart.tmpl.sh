app_port=1527
server_name="nninteractive-slicer-server"
server_image="/apps/brussel/containers/$server_name/$NNI_SVR_VER/$server_name-$NNI_SVR_VER.sif"

[[ -z $APPTAINERENV_HF_HUB_OFFLINE ]] && export APPTAINERENV_HF_HUB_OFFLINE=1
[[ -z $NNINTERACTIVE_WEIGHTS ]] && export NNINTERACTIVE_WEIGHTS="/databases/bio/nninteractive-slicer-server/$NNI_SVR_VER/weights"

module load "$MODULES_TO_LOAD"

unshare -rn bash -eu <<EOF
ip link set lo up

if nvidia-smi &>/dev/null ;then
    echo 'Starting nninteractive-slicer-server ...'
    apptainer run --nv $server_image python /opt/server/main.py --host 0.0.0.0 --port $app_port &>> "$OOD_SESSION_STAGED_ROOT/slicer-server.log" &
    server_pid=\$!
else
    echo 'Skipping nninteractive-slicer-server: no GPU available'
fi

echo 'Starting Slicer ...'
vglrun Slicer

[[ -n \$server_pid ]] && env kill --verbose \$server_pid
EOF
