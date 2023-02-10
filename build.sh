if ! command -v nim &> /dev/null
then
    echo "<the_command> could not be found"
    exit
fi

FILE=./build/cimgui.so
if ! test -f "$FILE"; then
    mkdir build
    echo "cimgui not found, building..."
    git clone --recursive https://github.com/nimgl/cimgui.git
    cd cimgui
    mkdir bld
    cd bld
    cmake ..
    make
    cp ./cimgui.so ../../build/cimgui.so
    cd ../..
fi
cd build
nim c -d:ssl --run -o:./pp ../gui.nim