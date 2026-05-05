#!/bin/bash
#Builds game files to .love, .exe for Windows, and linux binary
#Run `bash build.sh win64` for Windows
#Run `bash build.sh linux` for linux

if [ $# -ge "1" ]; then
    if [ $1 = "help" ]; then
        echo "Builds source code to .love and platform binaries."
        echo "=========================================================="
        echo "build.sh                   Builds game.love file to ./bin."
        echo ""
        echo "build.sh help                          Shows this message."
        echo ""
        echo "build.sh [win64|linux]         Builds game.love as well as"
        echo "                                platform-specific binaries"
        exit 0
    fi
fi

echo "Initiating build..."

BIN="./bin"
BUILD="./build"

ZIP_OUT="./bin/game.love"

LOVE_ZIP="$BUILD/love.zip"

echo "Initializing directories..."
mkdir -p $BUILD
mkdir -p $BIN

echo "Creating game.love..."
rm -f $ZIP_OUT
zip -9 -r $ZIP_OUT . -x@./.buildignore
echo "Created game.love"

if [ $# -ge "1" ]; then
    if [ $1 = "win64" ]; then
        echo "Building Windows executable..."

        LOVE_URL_WIN64="https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip"
        LOVE_EXE="$BUILD/love-11.5-win64/love.exe"
        BUILD_OUT="$BIN/win64/game.exe"

        mkdir -p "$BIN/win64"

        if [ -f $LOVE_EXE ]; then
            echo "Using love.exe at $LOVE_EXE"
        else
            if [ -f $LOVE_ZIP ]; then
                echo "Using love.zip at $LOVE_ZIP"
            else
                echo "Downloading love.zip..."
                rm -f $LOVE_ZIP
                wget $LOVE_URL_WIN64 -O $LOVE_ZIP
            fi

            unzip $LOVE_ZIP -n "*love.exe" -d ./build
        fi

        rm -f $BUILD_OUT
        cat $LOVE_EXE $ZIP_OUT > $BUILD_OUT
        echo "Built to $BUILD_OUT"
    elif [ $1 = "linux" ]; then
        echo "Building Linux binary"

        LOVE_URL_LINUX="https://github.com/love2d/love/releases/download/11.5/love-11.5-x86_64.AppImage"

        LOVE_APPIMAGE="$BUILD/love.AppImage"

        if [ -f $LOVE_APPIMAGE ]; then
            echo "Using love.AppImage at $LOVE_APPIMAGE"
        else
            echo "Downloading love.AppImage..."
            wget $LOVE_URL_LINUX -O $LOVE_APPIMAGE
        fi

        SFS_ROOT="$BUILD/squashfs-root"

        echo "Extracting AppImage..."
        rm -f -r "$SFS_ROOT"
        cd $BUILD
        chmod +x love.AppImage
        love.AppImage --appimage-extract
        cd ..

        cat "$SFS_ROOT/bin/love" $ZIP_OUT > "$SFS_ROOT/bin/game"
        chmod +x "$SFS_ROOT/bin/game"
        rm -f "$SFS_ROOT/bin/love"
        mv "$SFS_ROOT/bin/game" "$SFS_ROOT/bin/love"

        rm -f -r "$BIN/linux"
        mv "$SFS_ROOT" "$BIN/linux"

        cp ./LICENSE "$BIN/linux/LICENSE"
    else
        echo "Invalid platform identifier. Exiting without building platform binary."
    fi
fi

echo "Exiting script"