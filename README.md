# ros2-android-build

Build rcljava for android.  


## Versions & Envs

- NDK:  android-ndk-r23b
- ABI: arm64-v8a  
- Android API Level(minSdkVersion): android-21

## ROS2 java version  

https://raw.githubusercontent.com/ros2-java/ros2_java/434e6f55253bfe2cb9ce34799fe548bbf4998d0e/ros2_java_android.repos


## Steps to build

### 1. Build docker image
```
docker build -t ros2java-android-build ./
```

### 2. Build
```
python3 run.py ./out/soOut ./out/jarOut --srcDir ../src 
```
First and Second argument specifies where to copy build results.  
Eg. Specify `libs` and `jniLibs` dir of your Android project to copy `.jar` file and `.so` files.  

`--srcDir` option is using for adding packages other than ros2 java related packages, for example your own message package.  
You can just specify your `src` dir which contains multiple packages. This option is not mandatory.


## Note1   
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

## Note2 
Build `ros2_android` and `ros2_android_examples` by this Dockerfile is currently not supported.  
Please build your android app by using Android Studio.
