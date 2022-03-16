#!/bin/bash

cd /root/workspace
vcs import --input ./ros2_java_android.repos src

export PYTHON3_EXEC="$( which python3 )"
export PYTHON3_LIBRARY="$( ${PYTHON3_EXEC} -c 'import os.path; from distutils import sysconfig; print(os.path.realpath(os.path.join(sysconfig.get_config_var("LIBPL"), sysconfig.get_config_var("LDLIBRARY"))))' )"
export PYTHON3_INCLUDE_DIR="$( ${PYTHON3_EXEC} -c 'from distutils import sysconfig; print(sysconfig.get_config_var("INCLUDEPY"))' )"

colcon build \
    --packages-ignore cyclonedds rcl_logging_log4cxx rosidl_generator_py \
    --packages-up-to rcljava \
    --cmake-args \
    -DPYTHON_EXECUTABLE=${PYTHON3_EXEC} \
    -DPYTHON_LIBRARY=${PYTHON3_LIBRARY} \
    -DPYTHON_INCLUDE_DIR=${PYTHON3_INCLUDE_DIR} \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
    -DANDROID=ON \
    -DANDROID_FUNCTION_LEVEL_LINKING=OFF \
    -DANDROID_NATIVE_API_LEVEL=${ANDROID_TARGET} \
    -DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME} \
    -DANDROID_STL=c++_shared \
    -DANDROID_ABI=${ANDROID_ABI} \
    -DANDROID_NDK=${ANDROID_NDK} \
    -DTHIRDPARTY=ON  \
    -DCOMPILE_EXAMPLES=OFF \
    -DCMAKE_FIND_ROOT_PATH="${PWD}/install" \
    -DBUILD_TESTING=OFF \
    -DTHIRDPARTY_android-ifaddrs=FORCE