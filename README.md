# ros2-android-build

Build rcljava for android.  


## Steps to build
```
docker build -t ros2java-android-build ./

# without `--net=host`, vcs tools failed to fetch source code from github.
docker run -it --rm --net=host -v ${PWD}/output:/root/output ros2java-android-build /root/workspace/build-android.sh

```

Copy `.so` file and `.jar` files to your android project. 

↓Android project structure example.  
```
app
 -libs
    - jar files
 - src
    - main
        - java
        - jniLibs
            - arm64-v8a
                - .so files
        - res
        - AndroidManifest.xml

```