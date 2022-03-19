#!/usr/bin/env bash

sudo apt update -y && sudo apt upgrade -y
sudo apt install -y git cmake ninja-build golang openjdk-8-jdk python unzip

#Version Variable
CMDLVER='8092744'

# ANDROID_HOME is deprecated, but older versions of Gradle rely on it
export ANDROID_ROOT="$PWD/ANDROID"
export ANDROID_SDK_ROOT="${ANDROID_ROOT}/sdk"
export ANDROID_NDK_ROOT="${ANDROID_SDK_ROOT}/ndk-bundle"
export NINJA_PATH="$(which ninja)"

# Downlaod Sdk
mkdir -p "${ANDROID_SDK_ROOT}" && chmod -R a+rwx "${ANDROID_SDK_ROOT}"
wget "https://dl.google.com/android/repository/commandlinetools-linux-$CMDLVER_latest.zip"
unzip -qq commandlinetools-linux-*latest.zip -d "${ANDROID_SDK_ROOT}"/cmdline-tools
mv "${ANDROID_SDK_ROOT}"/cmdline-tools/cmdline-tools "${ANDROID_SDK_ROOT}"/cmdline-tools/latest
rm -rf ./*.zip*

# Install Ndk+cmake
PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_HOME/cmake/*/bin"
yes | sdkmanager ndk-bundle
export NDK="$ANDROID_HOME/ndk/*"

# Clone tgfoss
git clone --recursive --depth=1 -b master https://github.com/Telegram-FOSS-Team/Telegram-FOSS.git "$HOME"/tgfoss

# Make dependencies
cd "$HOME"/tgfoss/TMessagesProj/jni
chmod a+x ./*
./build_ffmpeg_clang.sh
./patch_ffmpeg.sh
./patch_boringssl.sh
./build_boringssl.sh
cd ../..
echo -e "APP_ID = $APP_ID\nAPP_HASH = $APP_HASH" >./API_KEYS
./gradlew assembleRelease
