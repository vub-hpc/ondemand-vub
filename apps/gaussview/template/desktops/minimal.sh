#
# Launch Xfce Window Manager and Panel
#

(
  export SEND_256_COLORS_TO_REMOTE=1
  export XDG_CACHE_HOME="$(mktemp -d)"
  set -x
  xfwm4 --compositor=off --sm-client-disable &
  xsetroot -solid "#D3D3D3"
  xfsettingsd --sm-client-disable &
  xfce4-panel --sm-client-disable &
) &

#
# Start your GUI app
#
# Launch ParaView
echo "Launching: $(which gview)"

vglrun gview
