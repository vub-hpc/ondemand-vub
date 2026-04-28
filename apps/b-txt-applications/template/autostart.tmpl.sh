mkdir -p $B_TXT_DATA

# Optionally use private namespace (maybe with slirp4netns)
# unshare -rn bash -eu <<EOF
# ip link set lo up

# APP_IMAGE is the relative path to image from /apps/brussel/containers
case "$APP_CHOICE" in
  label-studio )
    APP_IMAGE="/apps/brussel/containers/label-studio/label-studio.sif"
    apptainer run \
      --env "WEBSERVER_PORT=$WEBSERVER_PORT" \
      --bind $B_TXT_DATA:/app/data \
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
until curl --output /dev/null --silent --head --fail http://localhost:$WEBSERVER_PORT; do
    sleep 1
done
echo "$APP_CHOICE webserver is up."

# Create new firefox profile and start new isolated instance with that profile
firefox -CreateProfile "$SLURM_JOB_ID /tmp/ff-profile-$SLURM_JOB_ID"
firefox -no-remote -P "$SLURM_JOB_ID" localhost:$WEBSERVER_PORT$URL_SUFFIX

[[ -n \$app_pid ]] && env kill --verbose \$app_pid

#EOF 
