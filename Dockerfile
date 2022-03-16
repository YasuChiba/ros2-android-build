FROM ubuntu:20.04

ENV ANDROID_NDK_VERSION android-ndk-r23b
ENV ANDROID_TARGET android-23
ENV ANDROID_ABI arm64-v8a
ENV ANDROID_TOOLCHAIN_NAME aarch64-linux-android
ENV ANDROID_NDK /opt/android/${ANDROID_NDK_VERSION}
ENV CMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update
RUN apt install -y git vim cmake build-essential openjdk-8-jdk
RUN apt install -y unzip wget gradle python3-pip
RUN pip3 install -U colcon-common-extensions vcstool lark colcon-ros-gradle

RUN wget -O /tmp/android-ndk.zip https://dl.google.com/android/repository/${ANDROID_NDK_VERSION}-linux.zip && mkdir -p /opt/android/ && cd /opt/android/ && unzip -q /tmp/android-ndk.zip && rm /tmp/android-ndk.zip

RUN mkdir -p /root/workspace/src
RUN wget -O /root/workspace/ros2_java_android.repos https://raw.githubusercontent.com/ros2-java/ros2_java/434e6f55253bfe2cb9ce34799fe548bbf4998d0e/ros2_java_android.repos

# add spdlog
RUN echo "  ros2/spdlog_vendor:" >> /root/workspace/ros2_java_android.repos
RUN echo "    type: git" >> /root/workspace/ros2_java_android.repos
RUN echo "    url: https://github.com/ros2/spdlog_vendor.git" >> /root/workspace/ros2_java_android.repos
RUN echo "    version: galactic" >> /root/workspace/ros2_java_android.repos

COPY ./build-android.sh /root/workspace/
RUN chmod +x /root/workspace/build-android.sh
