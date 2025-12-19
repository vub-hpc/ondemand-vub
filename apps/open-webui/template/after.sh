# If no gpu, just finish the ood session
if nvidia-smi &>/dev/null ;then

  # Wait until Firefox has started
  while ! pgrep -x firefox > /dev/null; do
      sleep 1
  done
  echo "Firefox is up."
fi
