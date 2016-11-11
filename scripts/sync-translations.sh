#!/bin/sh

TOOL=tx

if ! hash $TOOL 2>/dev/null; then
    echo "Transifex command line tool not installed, see http://docs.transifex.com/client/"
    exit 1
fi

$TOOL pull -af

rm -rf Antidote/fr-FR.lproj
mv Antidote/fr_FR.lproj Antidote/fr-FR.lproj

rm -rf Antidote/zh-Hans-CN.lproj
mv Antidote/zh_CN.lproj Antidote/zh-Hans-CN.lproj

rm -rf fastlane/metadata/en-US
mv fastlane/metadata/en_US fastlane/metadata/en-US

rm -rf fastlane/metadata/fr-FR
mv fastlane/metadata/fr fastlane/metadata/fr-FR
