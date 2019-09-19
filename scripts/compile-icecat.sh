#!/bin/bash

set -e

version=68.1.0
archive=./icecat-${version}-gnu1.tar.bz2
folder=./icecat-${version}

function usage {
    echo "Usage: icebuild [command1 [command2 [...]]]"
    echo
    echo "Downloads, patches and builds GNU IceCat for macOS. Available"
    echo "commands:"
    echo
    echo "  build         Compile the sources"
    echo "  help          Display this message and exit"
    echo "  prepare       Download the sources and prepare them for"
    echo "                compilation"
    echo "  update_dmg    Copy the final DMG into the dmgs folder"
    echo
    echo "Multiple commands can be specified at once. If no commands"
    echo "are given, the script defaults to 'prepare build'."
    exit 0
}

function announce {
    echo -e "\033[93m|> $1\033[0m"
}

function die {
    echo -e "\e[31mError: $1\e[0m"
    exit 1
}

function fetch_archive {
    announce "Fetching source archive for ${version}"
    if [[ ! -f "${archive}" ]]; then
        curl -O "https://sagitter.fedorapeople.org/icecat/v68.1.0/icecat-68.1.0-gnu1.tar.bz2"
    else
        echo "Found previously downloaded archive ${archive}"
    fi
}

function extract_archive {
    announce "Extracting source archive"
    if [[ ! -d "${folder}" ]]; then
        tar xjfv "${archive}"
    else
        echo "Found previously extracted archive contents ${folder}"
    fi
}

function apply_patches {
    announce "Patching files"
    pushd "${folder}"
    while read -r file; do
        if ! patch -Rsf --dry-run -p0 -i "${file}" > /dev/null; then
            patch -p0 -i "${file}"
        else
            echo "$(basename "${file}") was already applied"
        fi
    done < <(find ../ -maxdepth 1 -name "*.patch")
    popd
}

function prepare_folders {
    announce "Preparing build folders"
    pushd "${folder}"
    cp ../icecat.icns browser/branding/official/icecat.icns
    mkdir -vp objdir
    mkdir -vp browser/branding/unofficial/moz.build
    popd
}

function build {
    announce "Building"
    pushd "${folder}/objdir"
    ../configure \
        --with-l10n-base=../l10n \
        --enable-official-branding \
        --with-macos-sdk=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk
    make -j12
    rm dist/IceCat.app/Contents/Resources/browser/extensions/https-everywhere-eff@eff.org/META-INF/cose.manifest
    rm dist/IceCat.app/Contents/Resources/browser/extensions/jid1-KtlZuoiikVfFew@jetpack/META-INF/cose.manifest
    make package
    popd
}

function update_dmg {
    local dmg=${folder}/objdir/dist/icecat-${version}.en-US.mac.dmg
    if [[ ! -f "${dmg}" ]]; then
        die "Could not find ${dmg}"
    fi
    local txt=${dmg%%.dmg}.txt
    if [[ ! -f "${txt}" ]]; then
        die "Could not find ${txt}"
    fi
    local name=$(basename "${dmg}")
    local ts=$(cat "${txt}")
    cp -v "${dmg}" "dmgs/${name%%.dmg}.${ts}.dmg"
}

# Handle help command
for arg in $@; do
    if [[ ${arg} == help ]]; then
        usage
    fi
done

# Default commands (if needed) and validate them
commands=${@-prepare build}
for command in ${commands}; do
    case "${command}" in
        prepare)
            ;;
        build)
            ;;
        update_dmg)
            ;;
        *)
            die "Invalid command ${command}"
            ;;
    esac
done

# Handle commands
for command in ${commands}; do
    case "${command}" in
        prepare)
            fetch_archive
            extract_archive
            apply_patches
            prepare_folders
            ;;
        build)
            build
            ;;
        update_dmg)
            update_dmg
            ;;
    esac
done