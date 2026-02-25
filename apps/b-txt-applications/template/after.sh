# Wait until Firefox has started
while ! pgrep -x firefox > /dev/null; do
    sleep 1
done
echo "Firefox is up."

# TODO do not wait if unsupported app chosen
