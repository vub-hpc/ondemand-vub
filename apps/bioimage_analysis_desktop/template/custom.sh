#!/bin/bash

BASHDEBUG=""

if [ -n "$BASHDEBUG" ]; then
    set "$BASHDEBUG"
    env | sort
fi

# Check if XDG_CONFIG_HOME was set as custom config dir
# If not, it was set to be inside $OOD_SESSION_STAGED_ROOT
# We will use BAND_CFG_HOME as the config directory for apps
# using user_config_dir
if [[ $XDG_CONFIG_HOME == $OOD_SESSION_STAGED_ROOT* ]]; then
    export BAND_CFG_HOME=$VSC_HOME/.config
else
    export BAND_CFG_HOME=$XDG_CONFIG_HOME
fi

# Store band desktop files in $XDG_DESKTOP_DIR folder
mkdir -p "$XDG_DESKTOP_DIR"

# Create plugin dir for Fiji
mkdir -p "$HOME"/.fiji_plugins

# Create settings file for napari
# This hash will always be the same (computed in Python as hashlib.sha1("3.13.1-GCCcore-14.2.0".encode()).hexdigest())
napari_cfg_dir="$BAND_CFG_HOME/napari/3.13.1-GCCcore-14.2.0_9d358b0655101f06a4539dec4955b9d31693a995"
mkdir -p "$napari_cfg_dir"
touch "$napari_cfg_dir/settings.yaml"

# Make band group for applications list
cat > "$XFCE_MERGED/band.menu" <<EOF
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
  <Name>BAND</Name>
  <Menu>
    <Name>Bioimage analysis</Name>
    <Include>
      <Category>BANDApplication</Category>
    </Include>
  </Menu>
</Menu>
EOF

ICONDIR="$OOD_SESSION_STAGED_ROOT/icons"

# Creates .desktop file given software name, version and full execution command as
# first, second and third argument
function make_band_desktop_path () {
    local name version exec_command
    name=$1
    version=$2
    exec_command=$3   

    local f
    f="$XDG_DESKTOP_DIR/${name}.desktop"
    if [ ! -e "$f" ]; then
      sed 's/^ \{4\}//' > "$f" << EOL
      [Desktop Entry]
      Encoding=UTF-8
      Name=$name $version
      GenericName=$name $version

      Exec="$exec_command"
      Icon=$ICONDIR/${name,,}.png
      Terminal=true
      StartupNotify=true
      Type=Application
      Categories=BANDApplication;
EOL
    fi
    gio set -t string "$f" metadata::xfce-exe-checksum "$(sha256sum "$f" | awk '{print $1}')"
    chmod +x "$f"
}

# Parse software name, version and create command to load module and execute the software
# Then create the .desktop file
# Takes modulename and command to load the software as first and second arguments
function make_band_desktop_path_module () {
    local module exec_command name version
    module=$1
    name="$(echo "$module" | cut -d '/' -f 1)"
    exec_command="bash -c 'export XDG_CONFIG_HOME=$BAND_CFG_HOME; echo \\\"Starting $name, please wait...\\\"; module load $module && vglrun $2'"
    version="$(echo "$module" | cut -d '/' -f 2 | cut -d '-' -f 1)"

    make_band_desktop_path "$name" "$version" "$exec_command"
}

# Declare bioimage modules and commands
declare -a modules=(
    "QuPath/0.6.0-GCCcore-14.2.0-Java-21"
    "napari/0.6.6-foss-2025a"
    "Fiji/2.14.0-Java-11"
)

# Use same order as modules array
declare -a module_commands=(
    "QuPath"
    "napari"
    "ImageJ-linux64 -Dimagej.updater.disableAutocheck=true \
    -Dij1.plugin.dirs=$HOME/.plugins:\$EBROOTFIJI/jars:\$EBROOTFIJI/plugins \
    --default-gc --java-home \$EBROOTJAVA/lib/server"
)

for i in "${!modules[@]}"; do
    make_band_desktop_path_module "${modules[i]}" "${module_commands[i]}"
done

# Declare bioimage containers
declare -a containers=(
    # Can probably be made into a module with next version (5.0.0)
    "/apps/brussel/containers/cellprofiler/CellProfiler-4.2.8.sif"
)

# Use same order as containers array
declare -a container_commands=(
    "cellprofiler"
)

# Parse software name, version and create command to execute the container
# Then create the .desktop file
# Takes absolute path to container and command to run the software (after apptainer exec <container> ...)
# as first and second argument.
function make_band_desktop_path_container () {
    local container exec_command local_filename name version
    container=$1

    # Remove everything up to final /
    local_filename="$(echo "$container" | rev |cut -d '/' -f 1 | rev)"
    # Assume container is named "<name>-<version>[-<suffix>].sif"
    name="$(echo "$local_filename" | cut -d '-' -f 1)"
    exec_command="bash -c 'export XDG_CONFIG_HOME=$BAND_CFG_HOME; echo \\\"Starting $name, please wait...\\\"; apptainer exec --nv $container $2'"



    version="$(echo "$local_filename" | cut -d '-' -f 2)"
    version="${version/.sif/""}"

    make_band_desktop_path "$name" "$version" "$exec_command" 
}

for i in "${!containers[@]}"; do
    make_band_desktop_path_container "${containers[i]}" "${container_commands[i]}"
done
