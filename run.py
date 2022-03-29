import argparse
from importlib.resources import path
import sys
import os
import pathlib
import urllib.request
import shutil
import subprocess
import glob

# --srcDir
#    package src directory in addition to rcljava related packages.
#     one of the srcDir or repoDir is required
# --repoFilePath
#    repo file path in addition to rcljava's repo file.

# --soOutDir
# --jarOutDir
# --clean


def getArgs():
    parser = argparse.ArgumentParser()

    parser.add_argument("soOutDir", help="output directory path of .so files", type=str)
    parser.add_argument("jarOutDir", help="output directory path of .jar files", type=str)
    parser.add_argument("--clean", help="clean build", action='store_true')

    additionalPackagesGroup = parser.add_mutually_exclusive_group()
    additionalPackagesGroup.add_argument("--srcDir", help="package src directory which contains packages in addition to rcljava related packages. rcljava related packages are automatically built.", type=str)
    additionalPackagesGroup.add_argument("--repoFile", help="repo file path which contains packages in addition to rcljava's repo file. rcljava related packages are automatically built.", type=str)
    

    args = parser.parse_args()
    return(args)


def setupRos2Java(workspacePath: pathlib.Path):
    repoFileUrl='https://raw.githubusercontent.com/ros2-java/ros2_java/434e6f55253bfe2cb9ce34799fe548bbf4998d0e/ros2_java_android.repos'
    repoFilePath = pathlib.Path(workspacePath, "ros2_java_android.repos")
    srcDirPath = pathlib.Path(workspacePath, "src")

    if not os.path.exists(repoFilePath):
        print("download repo file from ", repoFileUrl)
        urllib.request.urlretrieve(repoFileUrl, repoFilePath)

    if not os.path.exists(srcDirPath):
        os.makedirs(srcDirPath)
        print('start cloning ros2java related packages')
        command = f'docker run -it --rm --net=host -v {workspacePath}:/home/user/workspace ros2java-android-build vcs import --input /home/user/workspace/ros2_java_android.repos /home/user/workspace/src'
        subprocess.run(command, shell=True)


def build(workspacePath: pathlib.Path):
    print('start building packages')
    command = f'docker run -it --rm --net=host -v {workspacePath}:/home/user/workspace ros2java-android-build /home/user/build-android.sh'
    subprocess.run(command, shell=True)

def output(workspacePath: pathlib.Path, soOutPath: pathlib.Path, jarOutPath: pathlib.Path):
    soFiles = [f for f in glob.glob(str(workspacePath) + "/install/**/*.so", recursive=True)]
    jarFiles = [f for f in glob.glob(str(workspacePath) + "/install/**/*.jar", recursive=True)]

    for file in soFiles:
        filepath = pathlib.Path(file)
        distFilePath = soOutPath.joinpath(filepath.name)
        shutil.copyfile(file, distFilePath)
    
    for file in jarFiles:
        filepath = pathlib.Path(file)
        distFilePath = jarOutPath.joinpath(filepath.name)
        shutil.copyfile(file, distFilePath)

    # copy stdlib
    filepath = workspacePath.joinpath("libc++_shared.so")
    distFilePath = soOutPath.joinpath(filepath.name)
    shutil.copyfile(file, distFilePath)

def main():
    args = getArgs()

    workspacePath = pathlib.Path(pathlib.Path(__file__).resolve().parent, "tmp")
    workspaceAdditionalSrcDirPath = pathlib.Path(workspacePath, "additional-src")
    soOutPath = pathlib.Path(args.soOutDir).resolve()
    jarOutPath = pathlib.Path(args.jarOutDir).resolve()

    if workspaceAdditionalSrcDirPath.exists():
        shutil.rmtree(workspaceAdditionalSrcDirPath)

    if args.clean:
        if os.path.exists(workspacePath):
            shutil.rmtree(workspacePath)

    os.makedirs(workspacePath, exist_ok=True)
    os.makedirs(soOutPath, exist_ok=True)
    os.makedirs(jarOutPath, exist_ok=True)

    setupRos2Java(workspacePath)

    if args.srcDir is not None:
        additionalSrcDirPath = pathlib.Path(args.srcDir).resolve()
        shutil.copytree(additionalSrcDirPath, workspaceAdditionalSrcDirPath)

    if args.repoFile is not None:
        # TODO: need to implement
        raise NotImplementedError()

    build(workspacePath)
    output(workspacePath, soOutPath, jarOutPath)
    

if __name__ == '__main__':
    main()