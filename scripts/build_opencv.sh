#!/usr/bin/env sh

if [ -z "$NDK_ROOT" ] && [ "$#" -eq 0 ]; then
    echo 'Either $NDK_ROOT should be set or provided as argument'
    echo "e.g., 'export NDK_ROOT=/path/to/ndk' or"
    echo "      '${0} /path/to/ndk'"
    exit 1
else
    NDK_ROOT="${1:-${NDK_ROOT}}"
fi

ANDROID_ABI=${ANDROID_ABI:-"armeabi-v7a with NEON"}
WD=$(readlink -f "`dirname $0`/..")
OPENCV_ROOT=${WD}/opencv
INSTALL_DIR=${WD}/android_lib
N_JOBS=8

cd "${OPENCV_ROOT}/platforms"
rm -rf build_android_arm
mkdir -p build_android_arm
cd build_android_arm

cmake -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
      -DCMAKE_TOOLCHAIN_FILE="${WD}/android-cmake/android.toolchain.cmake" \
      -DANDROID_NDK="${NDK_ROOT}" \
      -DANDROID_NATIVE_API_LEVEL=21 \
      -DANDROID_ABI="${ANDROID_ABI}" \
      -D WITH_CUDA=OFF \
      -D BUILD_DOCS=OFF \
      -D BUILD_PERF_TESTS=OFF \
      -D BUILD_TESTS=OFF \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/opencv" \
      ../..

make -j${N_JOBS}
rm -rf "${INSTALL_DIR}/opencv"
make install/strip

cd "${WD}"
rm -rf ${OPENCV_ROOT}/platforms/build_android_arm/