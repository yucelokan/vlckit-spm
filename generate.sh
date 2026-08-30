#!/bin/sh

set -eu

TAG_VERSION="3.7.2"
UPSTREAM_BUILD="3e42ae47-79128878"
BASE_URL="https://download.videolan.org/cocoapods/prod"

BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/vlckit-spm-${TAG_VERSION}.XXXXXX")"
OUTPUT_DIR="${PWD}/dist"
OUTPUT_ZIP="${OUTPUT_DIR}/VLCKit-all.xcframework.zip"

cleanup() {
    rm -rf -- "${BUILD_DIR}"
}
trap cleanup EXIT INT TERM

mkdir -p "${OUTPUT_DIR}"

download_and_extract() {
    artifact="$1"
    archive="${BUILD_DIR}/${artifact}.tar.xz"
    curl --fail --location --retry 3 \
        --output "${archive}" \
        "${BASE_URL}/${artifact}-${TAG_VERSION}-${UPSTREAM_BUILD}.tar.xz"
    tar -xJf "${archive}" -C "${BUILD_DIR}"
}

download_and_extract "MobileVLCKit"
download_and_extract "VLCKit"
download_and_extract "TVVLCKit"

IOS_LOCATION="${BUILD_DIR}/MobileVLCKit-binary/MobileVLCKit.xcframework"
TVOS_LOCATION="${BUILD_DIR}/TVVLCKit-binary/TVVLCKit.xcframework"
MACOS_LOCATION="${BUILD_DIR}/VLCKit - binary package/VLCKit.xcframework"
COMBINED_FRAMEWORK="${BUILD_DIR}/VLCKit-all.xcframework"

#Merge into one xcframework
xcodebuild -create-xcframework \
    -framework "$MACOS_LOCATION/macos-arm64_x86_64/VLCKit.framework" \
    -debug-symbols "$MACOS_LOCATION/macos-arm64_x86_64/dSYMs/VLCKit.framework.dSYM" \
    -framework "$TVOS_LOCATION/tvos-arm64_x86_64-simulator/TVVLCKit.framework" \
    -debug-symbols "$TVOS_LOCATION/tvos-arm64_x86_64-simulator/dSYMs/TVVLCKit.framework.dSYM" \
    -framework "$TVOS_LOCATION/tvos-arm64/TVVLCKit.framework"  \
    -debug-symbols "$TVOS_LOCATION/tvos-arm64/dSYMs/TVVLCKit.framework.dSYM" \
    -framework "$IOS_LOCATION/ios-arm64_i386_x86_64-simulator/MobileVLCKit.framework" \
    -debug-symbols "$IOS_LOCATION/ios-arm64_i386_x86_64-simulator/dSYMs/MobileVLCKit.framework.dSYM" \
    -framework "$IOS_LOCATION/ios-arm64_armv7_armv7s/MobileVLCKit.framework" \
    -debug-symbols "$IOS_LOCATION/ios-arm64_armv7_armv7s/dSYMs/MobileVLCKit.framework.dSYM" \
    -output "${COMBINED_FRAMEWORK}"

rm -f -- "${OUTPUT_ZIP}"
ditto -c -k --sequesterRsrc --keepParent "${COMBINED_FRAMEWORK}" "${OUTPUT_ZIP}"

PACKAGE_HASH="$(swift package compute-checksum "${OUTPUT_ZIP}")"
cp -f "${BUILD_DIR}/MobileVLCKit-binary/COPYING.txt" ./LICENSE
echo "VLCKit ${TAG_VERSION} package created at ${OUTPUT_ZIP}"
echo "SwiftPM checksum: ${PACKAGE_HASH}"
