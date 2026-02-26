mkdir -p $B_TXT_DATA

# Optionally use private namespace (maybe with slirp4netns)
# unshare -rn bash -eu <<EOF
# ip link set lo up

# APP_IMAGE is the relative path to image from /apps/brussel/containers
case "$APP_CHOICE" in
  auscriptorium)
    APP_IMAGE="/apps/brussel/containers/auscriptorium/auscriptorium.sif"

    export AUSCRIPTORIUM_HANDOVER_TOKEN="$(uuidgen)"

    echo 'Auscriptorium data dir at $B_TXT_DATA'
    echo 'Starting auscriptorium...'
    apptainer run \
      --env "DJANGO_GUNICORN_WORKERS=3" \
      --env "DJANGO_NUM_BACKGROUND_WORKERS=2" \
      --env "AUSCRIPTORIUM_HANDOVER_ENABLED=TRUE" \
      --env "AUSCRIPTORIUM_HANDOVER_TOKEN=$AUSCRIPTORIUM_HANDOVER_TOKEN" \
      --env="AUSCRIPTORIUM_PORT=$WEBSERVER_PORT" \
      --bind $B_TXT_DATA:/app/persisted_data \
      $APP_IMAGE &>> "$OOD_SESSION_STAGED_ROOT/auscriptorium.log" &
    app_pid=\$!
    URL_SUFFIX="/login/handover?handover_token=$AUSCRIPTORIUM_HANDOVER_TOKEN"
    ;;
  label-studio )
    APP_IMAGE="/apps/brussel/containers/label-studio/label-studio.sif"
    apptainer run \
      --env "LABEL_STUDIO_LOCAL_FILES_SERVING_ENABLED=true" \
      --env "LABEL_STUDIO_PORT=$WEBSERVER_PORT" \
      --env "LABEL_STUDIO_DATABASE=/data/db.sqlite" \
      --env "LABEL_STUDIO_BASE_DATA_DIR=/data/files" \
      --bind $B_TXT_DATA:/data \
      $APP_IMAGE &>> "$OOD_SESSION_STAGED_ROOT/label-studio.log" &
    app_pid=\$!
    URL_SUFFIX=""
    ;;
  * )
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
firefox -no-remote -P "$SLURM_JOB_ID" --kiosk localhost:$WEBSERVER_PORT$URL_SUFFIX

[[ -n \$app_pid ]] && env kill --verbose \$app_pid

#EOF 
