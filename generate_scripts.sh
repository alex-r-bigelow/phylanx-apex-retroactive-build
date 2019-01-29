#!/bin/bash

BUILD_DATE=${1:-`date`}
BUILD_DATE=`date --date="$BUILD_DATE" +"%s"`
HUMAN_BUILD_DATE=`date --date=@$BUILD_DATE`

TARGET_DIR=${2:-"$HOME/build-$BUILD_DATE"}
BUILD_FILE="$TARGET_DIR/build.sh"
RUN_FILE="$TARGET_DIR/run.sh"

if [ -d $TARGET_DIR ]
then
  rm -rf $TARGET_DIR
fi
mkdir $TARGET_DIR
touch $BUILD_FILE
touch $RUN_FILE

# Add shebang to both scripts
echo "#!/bin/bash" | tee -a $BUILD_FILE $RUN_FILE >/dev/null

# Add date info to build script
echo "# Retroactive settings for building $BUILD_DATE (unix timestamp for $HUMAN_BUILD_DATE)" >> $BUILD_FILE
echo "export BUILD_DATE=\"$BUILD_DATE\"" >> $BUILD_FILE
echo "export HUMAN_BUILD_DATE=\"$HUMAN_BUILD_DATE\"" >> $BUILD_FILE

# Add TARGET_DIR to both scripts
echo "export TARGET_DIR=\"$TARGET_DIR\"" | tee -a $BUILD_FILE $RUN_FILE >/dev/null

# Load modules for both scripts
echo "module load clang/6.0.1" | tee -a $BUILD_FILE $RUN_FILE >/dev/null
echo "module load cmake/3.9.0" | tee -a $BUILD_FILE $RUN_FILE >/dev/null
echo "module load gperftools/2.7" | tee -a $BUILD_FILE $RUN_FILE >/dev/null
echo "module load boost/1.68.0-clang6.0.1" | tee -a $BUILD_FILE $RUN_FILE >/dev/null
echo "module load hwloc/2.0.0" | tee -a $BUILD_FILE $RUN_FILE >/dev/null
echo "module load papi/5.6.0"| tee -a $BUILD_FILE $RUN_FILE >/dev/null
echo "module load blaze/3.4" | tee -a $BUILD_FILE $RUN_FILE >/dev/null
echo "module load pybind11/2.2.4" | tee -a $BUILD_FILE $RUN_FILE >/dev/null
# echo "module load python/3.6.3s" | tee -a $BUILD_FILE $RUN_FILE >/dev/null

# Set OTF2 version in the build file
echo "export OTF2_VERSION=\"2.1.1\"" >> $BUILD_FILE

# Add HPX build settings to the build file
echo $'export HPX_PARAMS="\
 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 -DCMAKE_INSTALL_PREFIX=./ \
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
 -DOTF2_ROOT=\$OTF2_DIR/\$OTF2_VERSION \
 -DBUILD_OTF2=FALSE \
 -DBUILD_ACTIVEHARMONY=FALSE \
 -DAPEX_WITH_PAPI=TRUE \
 -DHPX_WITH_MAX_CPU_COUNT=72"' >> $BUILD_FILE

# Add HPX to the run file's LD_LIBRARY_PATH
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$TARGET_DIR/hpx/lib:\$TARGET_DIR/hpx/lib64" >> $RUN_FILE

# Add Phylanx build settings to the build file
echo $'export PHYLANX_PARAMS="\
  -DCMAKE_INSTALL_PREFIX=./ \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_COMPILER=`which clang++` \
  -DCMAKE_C_COMPILER=`which clang` \
  -DHPX_DIR=\$TARGET_DIR/hpx/lib64/cmake/HPX \
  -Dblaze_DIR=\$blaze_DIR \
  -Dpybind11_DIR=\$pybind11_DIR"' >> $BUILD_FILE

# Add Phylanx to the run file's LD_LIBRARY_PATH (TODO: PYTHONPATH as well?)
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$TARGET_DIR/phylanx/lib:\$TARGET_DIR/phylanx/lib64" >> $RUN_FILE

# Append the templates to each file
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cat $THIS_DIR/run_template.sh >> $RUN_FILE
cat $THIS_DIR/build_template.sh >> $BUILD_FILE
