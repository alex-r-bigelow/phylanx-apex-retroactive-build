#!/bin/bash

set -e

PROCS=$(lscpu | grep CPU.s.: | head -1 | cut -d: -f2)
USE_PROCS=$(($PROCS/2))

PARB_TARGET=${PARB_TARGET:-$HOME}

BUILD_DATE=${1:-`date`}
BUILD_DATE=`date --date="$BUILD_DATE" +"%s"`
HUMAN_BUILD_DATE=`date --date=@$BUILD_DATE`
BUILD_DIR=${BUILD_DIR:-"$PARB_TARGET/build-$BUILD_DATE"}
BUILD_FILE="$PARB_TARGET/build-$BUILD_DATE.sh"
RUN_FILE="$BUILD_DIR/run.sh"
if [ -d $BUILD_DIR ]
then
  rm -rf $BUILD_DIR
fi
mkdir $BUILD_DIR
touch $BUILD_FILE
touch $RUN_FILE
touch $BUILD_DIR/build_log.txt

echo "Starting retroactive build for $BUILD_DATE (unix timestamp for $HUMAN_BUILD_DATE)"
echo "Starting retroactive build for $BUILD_DATE (unix timestamp for $HUMAN_BUILD_DATE)" >> $BUILD_DIR/build_log.txt

echo "#!/bin/bash" >> $BUILD_FILE
echo "#!/bin/bash" >> $RUN_FILE
echo "# Retroactive settings for building $BUILD_DATE (unix timestamp for $HUMAN_BUILD_DATE)" >> $BUILD_FILE
echo "export BUILD_DATE=\"$HUMAN_BUILD_DATE\"" >> $BUILD_FILE

# Load modules
PARB_CLANG_VERSION=${PARB_CLANG_VERSION:-6.0.1}
echo "export PARB_CLANG_VERSION=\"$PARB_CLANG_VERSION\"" >> $BUILD_FILE
echo "module load clang/$PARB_CLANG_VERSION" >> $RUN_FILE
module load clang/$PARB_CLANG_VERSION

PARB_CMAKE_VERSION=${PARB_CMAKE_VERSION:-3.9.0}
echo "export PARB_CMAKE_VERSION=\"$PARB_CMAKE_VERSION\"" >> $BUILD_FILE
echo "module load cmake/$PARB_CMAKE_VERSION" >> $RUN_FILE
module load cmake/$PARB_CMAKE_VERSION

PARB_GPERFTOOLS_VERSION=${PARB_GPERFTOOLS_VERSION:-2.7}
echo "export PARB_GPERFTOOLS_VERSION=\"$PARB_GPERFTOOLS_VERSION\"" >> $BUILD_FILE
echo "module load gperftools/$PARB_GPERFTOOLS_VERSION" >> $RUN_FILE
module load gperftools/$PARB_GPERFTOOLS_VERSION

PARB_BOOST_VERSION=${PARB_BOOST_VERSION:-1.68.0-clang6.0.1-debug}
echo "export PARB_BOOST_VERSION=\"$PARB_BOOST_VERSION\"" >> $BUILD_FILE
echo "module load boost/$PARB_BOOST_VERSION" >> $RUN_FILE
module load boost/$PARB_BOOST_VERSION

PARB_HWLOC_VERSION=${PARB_HWLOC_VERSION:-2.0.0}
echo "export PARB_HWLOC_VERSION=\"$PARB_HWLOC_VERSION\"" >> $BUILD_FILE
echo "module load hwloc/$PARB_HWLOC_VERSION" >> $RUN_FILE
module load hwloc/$PARB_HWLOC_VERSION

PARB_PAPI_VERSION=${PARB_PAPI_VERSION:-5.6.0}
echo "export PARB_PAPI_VERSION=\"$PARB_PAPI_VERSION\"" >> $BUILD_FILE
echo "module load papi/$PARB_PAPI_VERSION" >> $RUN_FILE
module load papi/$PARB_PAPI_VERSION

PARB_BLAZE_VERSION=${PARB_BLAZE_VERSION:-3.4}
echo "export PARB_BLAZE_VERSION=\"$PARB_BLAZE_VERSION\"" >> $BUILD_FILE
echo "module load blaze/$PARB_BLAZE_VERSION" >> $RUN_FILE
module load blaze/$PARB_BLAZE_VERSION

PARB_PYBIND11_VERSION=${PARB_PYBIND11_VERSION:-2.2.4}
echo "export PARB_PYBIND11_VERSION=\"$PARB_PYBIND11_VERSION\"" >> $BUILD_FILE
echo "module load pybind11/$PARB_PYBIND11_VERSION" >> $RUN_FILE
module load pybind11/$PARB_PYBIND11_VERSION

PARB_PYTHON_VERSION=${PARB_PYTHON_VERSION:-3.6.3s}
echo "export PARB_PYTHON_VERSION=\"$PARB_PYTHON_VERSION\"" >> $BUILD_FILE
echo "module load python/$PARB_PYTHON_VERSION" >> $RUN_FILE
module load python/$PARB_PYTHON_VERSION

INSTALL_DIR=${INSTALL_DIR:-$PARB_TARGET/install}
if [ ! -d $INSTALL_DIR ]
then
  mkdir $INSTALL_DIR
fi
cd $INSTALL_DIR

# Install OTF2 if needed
PARB_OTF2_VERSION=${PARB_OTF2_VERSION:-2.1.1}
echo "export PARB_OTF2_VERSION=\"$PARB_OTF2_VERSION\"" >> $BUILD_FILE
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$INSTALL_DIR/otf2/$PARB_OTF2_VERSION/lib" >> $RUN_FILE
if [ ! -d $INSTALL_DIR/otf2 ]
then
  mkdir $INSTALL_DIR/otf2
fi
if [ ! -d $INSTALL_DIR/otf2/$PARB_OTF2_VERSION ]
then
  echo "Installing OTF2 $PARB_OTF2_VERSION"
  echo "Installing OTF2 $PARB_OTF2_VERSION" >> $BUILD_DIR/build_log.txt
  cd ~/
  wget http://www.vi-hps.org/upload/packages/otf2/otf2-$PARB_OTF2_VERSION.tar.gz
  tar -xzf otf2-$PARB_OTF2_VERSION.tar.gz
  cd otf2-$PARB_OTF2_VERSION
  ./configure CC=clang CXX=clang++ --prefix=$INSTALL_DIR/otf2/$PARB_OTF2_VERSION --enable-shared
  make -j $USE_PROCS
  make install
  cd ..
  rm -rf otf2-$PARB_OTF2_VERSION
  rm otf2-$PARB_OTF2_VERSION.tar.gz
fi

# Clone hpx if needed
if [ ! -d $INSTALL_DIR/hpx ]
then
  cd $INSTALL_DIR
  git clone https://github.com/STEllAR-GROUP/hpx.git &>> $BUILD_DIR/build_log.txt
fi
cd $INSTALL_DIR/hpx
# Set the state of the hpx repository to what it was on the requested date
HPX_HASH=`git rev-list -1 --before="$BUILD_DATE" master`
echo "Building HPX $HPX_HASH"
echo "Building HPX $HPX_HASH" >> $BUILD_DIR/build_log.txt
git checkout $HPX_HASH &>> $BUILD_DIR/build_log.txt

# Build hpx
DEFAULT_HPX_PARAMS="\
 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 -DCMAKE_INSTALL_PREFIX=$BUILD_DIR/hpx \
 -DCMAKE_C_COMPILER=`which clang` \
 -DCMAKE_CXX_COMPILER=`which clang++` \
 -DHPX_WITH_MALLOC=tcmalloc \
 -DHPX_WITH_THREAD_IDLE_RATES=ON \
 -DHPX_WITH_PARCELPORT_MPI=OFF \
 -DHPX_WITH_PARCEL_COALESCING=OFF \
 -DHPX_WITH_TOOLS=OFF \
 -DHPX_WITH_DYNAMIC_HPX_MAIN=OFF \
 -DHPX_WITH_APEX=TRUE \
 -DHPX_WITH_APEX_TAG=develop \
 -DHPX_WITH_APEX_NO_UPDATE=FALSE \
 -DAPEX_WITH_ACTIVEHARMONY=FALSE \
 -DAPEX_WITH_OTF2=TRUE \
 -DOTF2_ROOT=$INSTALL_DIR/otf2/$PARB_OTF2_VERSION \
 -DBUILD_OTF2=FALSE \
 -DBUILD_ACTIVEHARMONY=FALSE \
 -DAPEX_WITH_PAPI=TRUE \
 -DHPX_WITH_MAX_CPU_COUNT=72"
HPX_PARAMS=${HPX_PARAMS:-$DEFAULT_HPX_PARAMS}
echo "export HPX_PARAMS=\"$HPX_PARAMS\"" >> $BUILD_FILE
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$BUILD_DIR/hpx/lib:$BUILD_DIR/hpx/lib64" >> $RUN_FILE
rm -rf build
mkdir build
cd build
cmake $HPX_PARAMS .. &>> $BUILD_DIR/build_log.txt
make -j $USE_PROCS -l $USE_PROCS &>> $BUILD_DIR/build_log.txt
make install &>> $BUILD_DIR/build_log.txt

# Clone phylanx if needed
if [ ! -d $INSTALL_DIR/phylanx ]
then
  cd $INSTALL_DIR
  git clone https://github.com/STEllAR-GROUP/phylanx.git &>> $BUILD_DIR/build_log.txt
fi
cd $INSTALL_DIR/phylanx
# Set the state of the phylanx repository to what it was on the requested date
PHYLANX_HASH=`git rev-list -1 --before="$BUILD_DATE" master`
echo "Building Phylanx $PHYLANX_HASH"
echo "Building Phylanx $PHYLANX_HASH" >> $BUILD_DIR/build_log.txt
git checkout $PHYLANX_HASH &>> $BUILD_DIR/build_log.txt

# Build Phylanx
DEFAULT_PHYLANX_PARAMS="\
  -DCMAKE_INSTALL_PREFIX=$BUILD_DIR/phylanx \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_COMPILER=`which clang++` \
  -DCMAKE_C_COMPILER=`which clang` \
  -DHPX_DIR=$INSTALL_DIR/hpx/build/lib/cmake/HPX \
  -Dblaze_DIR=$blaze_DIR \
  -Dpybind11_DIR=$pybind11_DIR"
PHYLANX_PARAMS=${PHYLANX_PARAMS:-$DEFAULT_PHYLANX_PARAMS}
echo "export PHYLANX_PARAMS=\"$PHYLANX_PARAMS\"" >> $BUILD_FILE
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$BUILD_DIR/phylanx/lib:$BUILD_DIR/phylanx/lib64" >> $RUN_FILE
rm -rf build
mkdir build
cd build
cmake $PHYLANX_PARAMS .. &>> $BUILD_DIR/build_log.txt
make -j $USE_PROCS -l $USE_PROCS &>> $BUILD_DIR/build_log.txt
make install &>> $BUILD_DIR/build_log.txt

echo "/bin/bash `pwd`/build.sh" >> $BUILD_FILE
cp $RUN_FILE $BUILD_DIR/test.sh
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cat $THIS_DIR/run.sh >> $RUN_FILE
cat $THIS_DIR/test.sh >> $BUILD_DIR/test.sh

echo "Finished retroactive build for $BUILD_DATE (unix timestamp for $HUMAN_BUILD_DATE)"
echo "Finished retroactive build for $BUILD_DATE (unix timestamp for $HUMAN_BUILD_DATE)" >> $BUILD_DIR/build_log.txt
