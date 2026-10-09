# gz-sim looks for system plugins in GZ_SIM_SYSTEM_PLUGIN_PATH, ~/.gz/sim/plugins and
# its own plugin directory. Other packages (e.g. ROS' gz_ros2_control) install theirs
# into the environment's lib/, which a ROS setup script would add: add it here.
export CONDA_BACKUP_GZ_SIM_SYSTEM_PLUGIN_PATH="${GZ_SIM_SYSTEM_PLUGIN_PATH:-}"
export GZ_SIM_SYSTEM_PLUGIN_PATH="${GZ_SIM_SYSTEM_PLUGIN_PATH:+${GZ_SIM_SYSTEM_PLUGIN_PATH}:}${CONDA_PREFIX}/lib"
