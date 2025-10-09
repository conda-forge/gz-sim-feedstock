#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -Dgz-msgs_PYTHON_INTERPRETER=$BUILD_PREFIX/bin/python -Dgz-msgs_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc -Dgz-msgs_PROTO_GENERATOR_PLUGIN=$BUILD_PREFIX/bin/gz-msgs_protoc_plugin"
fi

# We set SKIP_PYBIND11 to False, as pybind11 is used to compile the gz::sim::systems::PythonSystemLoader 
# (see "Gazebo Systems written in Python" in https://gazebosim.org/api/sim/8/python_interfaces.html)
# Python bindings itself are compiled instead in bld_py.bat, so the compilation for those is disabled
# by the standalone_bindings.patch patch
export SKIP_PYBIND11=OFF

# In cross-compilation, we need to let know Qt where to find codegen tools in the build environment
# See https://github.com/conda-forge/qt-main-feedstock/issues/273
if [[ "$build_platform" != "$target_platform" ]]; then
    export CMAKE_ARGS="$CMAKE_ARGS -DQT_HOST_PATH=$BUILD_PREFIX"
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=OFF \
      -DGZ_ENABLE_RELOCATABLE_INSTALL:BOOL=ON \
      -DSKIP_PYBIND11:BOOL=$SKIP_PYBIND11 \
      -DPython3_EXECUTABLE:PATH=$PYTHON

cmake --build . --config Release
cmake --build . --config Release --target install

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release 
fi
