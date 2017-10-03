# Android builder docker container

This fork uses the new `sdkmanager` toolchain to install the required SDK packages.

## Build the container image:

    docker build -t guardian/android-build-environment .

## Build the Android project

    cd /path/to/your/android/source/root
    docker run --rm -i -v $PWD:/project -t guardian/android-build-environment echo "sdk.dir=$ANDROID_HOME" > local.properties && <build command here>
