#!/bin/bash

BASHDEBUG=""

if [ -n "$BASHDEBUG" ]; then
    set "$BASHDEBUG"
    env | sort
fi

# Store band desktop files in separate folder
mkdir -p "$XFCE_APPLICATIONS/band"

# Create plugin dir for Fiji
mkdir -p "$HOME"/.fiji_plugins

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

    sed 's/^ \{4\}//' > "$XFCE_APPLICATIONS/band/${name}.desktop" << EOL
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
    local f
    f="$XFCE_APPLICATIONS/band/${name}.desktop"
    gio set -t string "$f" metadata::xfce-exe-checksum "$(sha256sum "$f" | awk '{print $1}')"
    chmod +x "$f"
}

# Parse software name, version and create command to load module and execute the software
# Then create the .desktop file
# Takes modulename and command to load the software as first and second arguments
function make_band_desktop_path_module () {
    local module exec_command name version
    module=$1
    exec_command="bash -c 'module load $module && $2'"

    name="$(echo "$module" | cut -d '/' -f 1)"
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
    #
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
    exec_command="apptainer exec $container $2"

    # Remove everything up to final /
    local_filename="$(echo "$container" | rev |cut -d '/' -f 1 | rev)"
    # Assume container is named "<name>-<version>[-<suffix>].sif"
    name="$(echo "$local_filename" | cut -d '-' -f 1)"
    version="$(echo "$local_filename" | cut -d '-' -f 2)"
    version="${version/.sif/""}"

    make_band_desktop_path "$name" "$version" "$exec_command" 
}

for i in "${!containers[@]}"; do
    make_band_desktop_path_container "${containers[i]}" "${container_commands[i]}"
done
