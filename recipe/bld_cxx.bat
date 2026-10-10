rmdir /s /q build
mkdir build
cd build

:: We set SKIP_PYBIND11 to False, as pybind11 is used to compile the gz::sim::systems::PythonSystemLoader
:: (see " Gazebo Systems written in Python" in https://gazebosim.org/api/sim/8/python_interfaces.html)
:: Python bindings itself are compiled instead in bld_py.bat, so the compilation for those is disabled
:: by the standalone_bindings.patch patch
set SKIP_PYBIND11=False


cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True ^
    -DBUILD_TESTING:BOOL=OFF ^
    -DGZ_ENABLE_RELOCATABLE_INSTALL:BOOL=ON ^
    -DSKIP_PYBIND11:BOOL=%SKIP_PYBIND11% ^
    -DPython3_EXECUTABLE:PATH=%PYTHON% ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release
if errorlevel 1 exit 1

:: Workaround for https://github.com/conda-forge/gz-sim-feedstock/issues/110#issuecomment-3389498040
:: and https://github.com/conda-forge/qt-main-feedstock/issues/275
:: Note that also qt6.conf contains an absolute path to the prefix, but as it is a textual file
:: the replacement is handled correctly by conda also on Windows
copy %PREFIX%\Library\bin\qt6.conf %PREFIX%\Library\libexec\gz\sim10\

:: gz-sim looks for system plugins in GZ_SIM_SYSTEM_PLUGIN_PATH, ~/.gz/sim/plugins and
:: its own plugin directory; other packages install theirs into Library\bin: set it on
:: activation (etc/conda/env_vars.d, CEP 34; forward slashes keep the JSON valid, and the
:: prefix is replaced at installation)
if not exist %PREFIX%\etc\conda\env_vars.d mkdir %PREFIX%\etc\conda\env_vars.d
set "FWD_PREFIX=%PREFIX:\=/%"
echo {"GZ_SIM_SYSTEM_PLUGIN_PATH": "%FWD_PREFIX%/Library/bin"} > %PREFIX%\etc\conda\env_vars.d\%PKG_NAME%.json
if errorlevel 1 exit 1
