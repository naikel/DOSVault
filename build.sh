#!/bin/sh
if [ -n "$1" ]; then
    BUILD_DIR="$1"
else
    BUILD_DIR="${HOME}/DOSVault-build"
fi
REPO_DIR="${PWD}"

LAST_TAG=$(git describe --abbrev=0 --tags)
if [ $? -eq 1 ]; then
    LAST_TAG="unknown"
fi
LAST_COMMIT=$(git log -1 --decorate --oneline)
echo ${LAST_COMMIT} | grep "tag: ${LAST_TAG}" 2>&1 >/dev/null
if [ $? -eq 1 ]; then
    VERSION="${LAST_TAG}+$(echo ${LAST_COMMIT} | awk '{ print $1 }')"
else
    VERSION="${LAST_TAG}"
fi
printf "#!/bin/bash\ndosvault_version=%s\n" "${VERSION}" > libexec/version.sh
chmod +x libexec/version.sh

echo Building DOSVAULT version ${VERSION}
mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/repo
cd ${BUILD_DIR}
flatpak-builder --repo=repo --force-clean --install-deps-from=flathub app ${REPO_DIR}/com.yappari.DOSVault.yaml
flatpak build-bundle repo com.yappari.DOSVault.flatpak com.yappari.DOSVault
cd ${REPO_DIR}
