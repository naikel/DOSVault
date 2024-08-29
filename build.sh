#!/bin/sh
BUILD_DIR=$HOME/DOSVault-build
REPO_DIR=$PWD

mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/repo
cd ${BUILD_DIR}
flatpak-builder --repo=repo --force-clean --keep-build-dirs --install-deps-from=flathub app ${REPO_DIR}/com.yappari.DOSVault.yaml
flatpak build-bundle repo com.yappari.DOSVault.flatpak com.yappari.DOSVault
cd ${REPO_DIR}
