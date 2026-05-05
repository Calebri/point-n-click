#!/bin/bash

echo Initiating build...

ZIP_OUT="./build/game.love"

LOVE_URL="https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip"
LOVE_ZIP="./build/love.zip"

LOVE="./build/love-11.5-win64/love.exe"

BUILD_OUT="./bin/game.exe"

mkdir build

rm -f $ZIP_OUT
zip -9 -r $ZIP_OUT . -x@./.buildignore

if [ -f $LOVE ]; then
    echo "Using love.exe at $LOVE"
else
    if [ ! -f $LOVE_ZIP ]; then
        echo "Downloading love.zip"
        rm -f $LOVE_ZIP
        wget $LOVE_URL -O $LOVE_ZIP
    fi

    unzip $LOVE_ZIP -n "*love.exe" -d ./build
fi

mkdir bin
rm -f $BUILD_OUT
cat $LOVE $ZIP_OUT > $BUILD_OUT

echo Build finished