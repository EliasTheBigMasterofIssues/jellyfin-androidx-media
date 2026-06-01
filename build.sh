#!/bin/bash

# Ensure NDK is available
export ANDROID_NDK_PATH=$ANDROID_HOME/ndk/26.1.10909125

[[ ! -d "$ANDROID_NDK_PATH" ]] && echo "No NDK found, quitting…" && exit 1

# Setup environment
export ANDROIDX_MEDIA_ROOT="${PWD}/media"
export FFMPEG_MOD_PATH="${ANDROIDX_MEDIA_ROOT}/libraries/decoder_ffmpeg/src/main"
export MPEGH_MOD_PATH="${ANDROIDX_MEDIA_ROOT}/libraries/decoder_mpegh/src/main"
export FFMPEG_PATH="${PWD}/ffmpeg"
export ENABLED_DECODERS=(flac alac pcm_mulaw pcm_alaw mp3 aac ac3 eac3 dca mlp truehd)

# Create softlink to ffmpeg
ln -sf "${FFMPEG_PATH}" "${FFMPEG_MOD_PATH}/jni/ffmpeg"

# Start build
git clone https://github.com/Fraunhofer-IIS/mpeghdec.git --branch r3.0.2 --depth=1 "${FFMPEG_MOD_PATH}/jni/libmpegh" 
cd "${MPEGH_MOD_PATH}/jni/"
cmake -S "${MPEGH_MOD_PATH}/jni/libmpegh" -B . \
  -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK_PATH}/build/cmake/android.toolchain.cmake" \
  -DCMAKE_ANDROID_NDK="${ANDROID_NDK_PATH}" \
  -DANDROID_ABI=armeabi-v7a \ 
  -DANDROID_PLATFORM=android-23 \
  -DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DCMAKE_SYSTEM_NAME=Android \
  -DCMAKE_SYSTEM_VERSION=23 \
  -Dmpeghdec_BUILD_DECODE=ON \
  -Dmpeghdec_BUILD_BINARIES=OFF \
  -DUSE_PKGCONFIG_DEPS=OFF \
  -dmpeghdec_BUILD_DOC=OFF \

cmake --build .

# Build ffmpeg
cd "${FFMPEG_MOD_PATH}/jni"
./build_ffmpeg.sh "${FFMPEG_MOD_PATH}" "${ANDROID_NDK_PATH}" "linux-x86_64" 23 "${ENABLED_DECODERS[@]}"

