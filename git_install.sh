#!/bin/bash

PROCS=$(lscpu | grep CPU.s.: | head -1 | cut -d: -f2)
USE_PROCS=$(($PROCS/2))

git clone --depth=1 $1 /temp
cd /temp
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$INSTALL $2 ..
make -j $USE_PROCS -l $USE_PROCS
make install
cd /
rm -rf /temp
