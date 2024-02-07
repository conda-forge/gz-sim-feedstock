#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -Dgz-msgs10_PYTHON_INTERPRETER=$BUILD_PREFIX/bin/python -Dgz-msgs10_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc -Dgz-msgs10_PROTO_GENERATOR_PLUGIN=$BUILD_PREFIX/bin/gz-msgs10_protoc_plugin"
fi

export SKIP_PYBIND11=ON  # python bindings are built in build_python.sh

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
