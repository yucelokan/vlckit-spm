#!/bin/sh

set -eu

TAG_VERSION="3.7.4"
BASE_URL="https://download.videolan.org/pub/cocoapods/prod"

# VideoLAN publishes the 3.7.4 archives under their CI build names. The names
# and SHA-256 values are the ones the official 3.7.4 podspecs document
# (Packaging/podspecs on VLCKit's 3.0 branch, "Pods: document the 3.7.4 release").
MOBILE_ARCHIVE="MobileVLCKit-3.0-20260922-1512.tar.xz"
MOBILE_SHA256="c649c4c47bd065b3a5511746361b5a9066a34033f2df9cbc9454409c0f363b52"
TV_ARCHIVE="TVVLCKit-3.0-20260930-0854.tar.xz"
TV_SHA256="07892cae8e59e95a23f1fcf11692f802eae106312aa5ad9782faa2556b2d65d5"
MACOS_ARCHIVE="VLCKit-3.0-20260922-1444.tar.xz"
MACOS_SHA256="d57a80455900e031ec87b08bdc684ba58989f9cec317b04739b2ee6b1d7a1868"

BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/vlckit-spm-${TAG_VERSION}.XXXXXX")"
OUTPUT_DIR="${PWD}/dist"
OUTPUT_ZIP="${OUTPUT_DIR}/VLCKit-all.xcframework.zip"

cleanup() {
    rm -rf -- "${BUILD_DIR}"
}
trap cleanup EXIT INT TERM

mkdir -p "${OUTPUT_DIR}"

download_and_extract() {
    archive_name="$1"
    expected_sha256="$2"
    archive="${BUILD_DIR}/${archive_name}"
    curl --fail --location --retry 3 \
        --output "${archive}" \
        "${BASE_URL}/${archive_name}"
    actual_sha256="$(shasum -a 256 "${archive}" | cut -d ' ' -f 1)"
    if [ "${actual_sha256}" != "${expected_sha256}" ]; then
        echo "error: ${archive_name} SHA-256 ${actual_sha256} does not match ${expected_sha256}" >&2
        exit 1
    fi
    tar -xJf "${archive}" -C "${BUILD_DIR}"
}

download_and_extract "${MOBILE_ARCHIVE}" "${MOBILE_SHA256}"
download_and_extract "${MACOS_ARCHIVE}" "${MACOS_SHA256}"
download_and_extract "${TV_ARCHIVE}" "${TV_SHA256}"

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
    -framework "$IOS_LOCATION/ios-arm64_x86_64-simulator/MobileVLCKit.framework" \
    -debug-symbols "$IOS_LOCATION/ios-arm64_x86_64-simulator/dSYMs/MobileVLCKit.framework.dSYM" \
    -framework "$IOS_LOCATION/ios-arm64_armv7_armv7s/MobileVLCKit.framework" \
    -debug-symbols "$IOS_LOCATION/ios-arm64_armv7_armv7s/dSYMs/MobileVLCKit.framework.dSYM" \
    -output "${COMBINED_FRAMEWORK}"

rm -f -- "${OUTPUT_ZIP}"
ditto -c -k --sequesterRsrc --keepParent "${COMBINED_FRAMEWORK}" "${OUTPUT_ZIP}"

PACKAGE_HASH="$(swift package compute-checksum "${OUTPUT_ZIP}")"
cp -f "${BUILD_DIR}/MobileVLCKit-binary/COPYING.txt" ./LICENSE
echo "VLCKit ${TAG_VERSION} package created at ${OUTPUT_ZIP}"
echo "SwiftPM checksum: ${PACKAGE_HASH}"
