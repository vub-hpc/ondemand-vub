# We check GPU presence again. Otherwise session will never start since
# Firefox never starts and wait forever.
# If no GPU, ood session should terminate.
if nvidia-smi &>/dev/null ;then

  # Wait until Firefox has started
  while ! pgrep -x firefox > /dev/null; do
      sleep 1
  done
  echo "Firefox is up."
fi
