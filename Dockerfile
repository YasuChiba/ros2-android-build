FROM ubuntu:20.04

# setup non-root user
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
#--------------------------------------------------------------------------------------------

ENV ANDROID_NDK_VERSION android-ndk-r23b
ENV ANDROID_TARGET android-21
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

RUN mkdir -p /home/${USERNAME}/workspace/

COPY ./build-android.sh /home/${USERNAME}/
RUN chmod +x /home/${USERNAME}/build-android.sh


#Android SDK
#only needed if you want to build android related packages
#ENV ANDROID_SDK_ROOT "/opt/android/sdk"
#ENV ANDROID_HOME "/opt/android/sdk"
#RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools
#RUN wget -O /tmp/android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip && unzip /tmp/android-sdk.zip -d $ANDROID_SDK_ROOT/cmdline-tools && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/tools && rm /tmp/android-sdk.zip

#RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --licenses
#RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --verbose "platform-tools" "platforms;${ANDROID_TARGET}"

USER $USERNAME
WORKDIR /home/$USERNAME/