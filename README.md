# ros2-android-build

Build rcljava for android.  


## Versions & Envs

- NDK:  android-ndk-r23b
- ABI: arm64-v8a  
- Android API Level(minSdkVersion): android-21

## ROS2 java version  

https://raw.githubusercontent.com/ros2-java/ros2_java/434e6f55253bfe2cb9ce34799fe548bbf4998d0e/ros2_java_android.repos


## Steps to build
```
docker build -t ros2java-android-build ./

# without `--net=host`, vcs tools failed to fetch source code from github.
docker run -it --rm --net=host -v ${PWD}/output:/root/output ros2java-android-build /root/workspace/build-android.sh

```

Build results are copied to `{PWD}/output` dir.  
Copy `.so` file and `.jar` files to your android project. 

↓Android project structure example.  
```
app
 -libs
    - .jar files
 - src
    - main
        - java
        - jniLibs
            - arm64-v8a
                - .so files
        - res
        - AndroidManifest.xml

```
Refer to example project: https://github.com/YasuChiba/ros2-android-test-app

## Note  
Build `ros2_android` and `ros2_android_examples` by this Dockerfile is currently not supported.  
Please build your android app by using Android Studio.
