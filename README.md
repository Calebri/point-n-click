# point-n-click (title pending)

Prototype for college project in [LÖVE](https://love2d.org).

## Running from source

Requires Git and [LÖVE](https://love2d.org).

1. Clone source.
```sh
git clone https://github.com/Calebri/point-n-click.git
```
2. Move to repo directory.
```sh
cd point-n-click
```
3. Run LÖVE in repo directory.
```sh
love .
```

## Building from source

Building from source can be done using the built-in build script, which can automatically download the required verison of [LÖVE](https://love2d.org) and create executables for Windows and Linux. 

1. Clone source.
```sh
git clone https://github.com/Calebri/point-n-click.git
```

### Building for Windows

If you are on Windows, you need to find a way to run Bash scripts in the terminal.

2. Run the build script with `win64` as a parameter.
```sh
./build.sh win64
```
3. The game executable and DLLs can be found in `./bin/win64`.

### Building for Linux

LÖVE documentation reccomends running LÖVE projects off of the `.love` packages, but the build script also has functionality for building Linux executables.

2. Run the build script with `linux` as a parameter.
```sh
./build.sh linux
```
3. Game binaries can be found in `./bin/linux`. The `AppRun` script should automatically start the game. Game executable is at `./bin/linux/bin/love`.

## Packaging to `.love`.

The build script can also make `.love` files, if you want to use them to build to another platform or run them this way instead.

1. Clone source.
```sh
git clone https://github.com/Calebri/point-n-click.git
```
2. Run the build script.
```sh
./build.sh
```
3. Packaged file can be found at `./bin/game.love`. Can be run from the package with the following command.
```sh
love ./bin/game.love
```