@REM gz-sim looks for system plugins in GZ_SIM_SYSTEM_PLUGIN_PATH, ~/.gz/sim/plugins and
@REM its own plugin directory. Other packages (e.g. ROS' gz_ros2_control) install theirs
@REM into the environment's Library\bin, which a ROS setup script would add: add it here.
@set "CONDA_BACKUP_GZ_SIM_SYSTEM_PLUGIN_PATH=%GZ_SIM_SYSTEM_PLUGIN_PATH%"
@if defined GZ_SIM_SYSTEM_PLUGIN_PATH (
  @set "GZ_SIM_SYSTEM_PLUGIN_PATH=%GZ_SIM_SYSTEM_PLUGIN_PATH%;%CONDA_PREFIX%\Library\bin"
) else (
  @set "GZ_SIM_SYSTEM_PLUGIN_PATH=%CONDA_PREFIX%\Library\bin"
)
