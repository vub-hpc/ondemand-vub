mkdir -p $B_TXT_DATA

# get free port - taken from https://stackoverflow.com/a/78125240
local_app_port=15000

while [ -n "$(ss -tan4H "sport = $local_app_port")" ]; do
  local_app_port=$((port+1))
done

echo "Usable Port: $local_app_port"

# APP_IMAGE is the path to image (should be in /apps/brussel/containers)
case "$APP_CHOICE" in
  label-studio )
    APP_IMAGE="/apps/brussel/containers/label-studio/label-studio.sif"
    apptainer run \
      --env "WEBSERVER_PORT=${local_app_port}" \
      --bind $B_TXT_DATA:/app/data \
      --contain \
      $APP_IMAGE &>> "$OOD_SESSION_STAGED_ROOT/label-studio.log" &
    app_pid=\$!
    URL_SUFFIX=""
    ;;
  * )
    # If portal was chosen we should not launch the desktop
    echo "ERROR: Unsupported app chosen: $APP_CHOICE"
    exit 1
    ;;
esac

echo "Waiting for webserver to start..."
until curl --output /dev/null --silent --head --fail http://localhost:${local_app_port}; do
    sleep 1
done
echo "$APP_CHOICE webserver is up."

# Create new firefox profile and start new isolated instance with that profile
firefox -CreateProfile "$SLURM_JOB_ID /tmp/ff-profile-$SLURM_JOB_ID"
firefox -no-remote -P "$SLURM_JOB_ID" localhost:${local_app_port}$URL_SUFFIX

[[ -n \$app_pid ]] && env kill --verbose \$app_pid