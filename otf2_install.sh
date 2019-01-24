#!/bin/bash

PROCS=$(lscpu | grep CPU.s.: | head -1 | cut -d: -f2)
USE_PROCS=$(($PROCS/2))

# Install OTF2
OTF2_DIR=otf2-2.1.1
wget http://www.vi-hps.org/upload/packages/otf2/$OTF2_DIR.tar.gz
tar -xzvf $OTF2_DIR.tar.gz temp
cd $OTF2_DIR
./configure CC=clang CXX=clang++ --prefix=$INSTALL/otf2 --enable-shared
make -j $USE_PROCS
make install
cd /
rm -rf $OTF2_DIR
