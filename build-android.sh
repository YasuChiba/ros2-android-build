#!/bin/bash
set -eu

cd /root/workspace

export PYTHON3_EXEC="$( which python3 )"
export PYTHON3_LIBRARY="$( ${PYTHON3_EXEC} -c 'import os.path; from distutils import sysconfig; print(os.path.realpath(os.path.join(sysconfig.get_config_var("LIBPL"), sysconfig.get_config_var("LDLIBRARY"))))' )"
export PYTHON3_INCLUDE_DIR="$( ${PYTHON3_EXEC} -c 'from distutils import sysconfig; print(sysconfig.get_config_var("INCLUDEPY"))' )"


wget -O /root/workspace/ros2_java_android.repos https://raw.githubusercontent.com/ros2-java/ros2_java/434e6f55253bfe2cb9ce34799fe548bbf4998d0e/ros2_java_android.repos

vcs import --input ./ros2_java_android.repos src

colcon build \
    --packages-ignore cyclonedds rcl_logging_log4cxx rcl_logging_spdlog rosidl_generator_py \
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
    -DRCL_LOGGING_IMPLEMENTATION=rcl_logging_noop \
    -DTHIRDPARTY_android-ifaddrs=FORCE \


# OUTPUT
rm -rf ~/output/sofiles
rm -rf ~/output/jarfiles

mkdir -p ~/output/sofiles
mkdir -p ~/output/jarfiles

find ./install -name "*.so" | while read t; do cp -p $t ~/output/sofiles/ ; done
find ./install -name "*.jar" | while read t; do cp -p $t ~/output/jarfiles/ ; done

# copy libc++_shared.so
cp /opt/android/android-ndk-r23b/sources/cxx-stl/llvm-libc++/libs/${ANDROID_ABI}/libc++_shared.so ~/output/sofiles