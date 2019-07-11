
set -e

PROCS=$(lscpu | grep CPU.s.: | head -1 | cut -d: -f2)
USE_PROCS=$(($PROCS/2))

LOG_FILE="$TARGET_DIR/build_log.txt"
touch $LOG_FILE

echo $'\n\n\n#####\n' >> $LOG_FILE
echo "Starting retroactive build for $BUILD_DATE (unix timestamp for $HUMAN_BUILD_DATE)" >> $LOG_FILE

# Install OTF2 if needed
if [ ! -d $OTF2_DIR ]
then
  mkdir $OTF2_DIR
fi
if [ ! -d $OTF2_DIR/$OTF2_VERSION ]
then
  echo "Installing OTF2 $OTF2_VERSION in $OTF2_DIR" |& tee -a $LOG_FILE
  cd $OTF2_DIR
  wget https://www.vi-hps.org/cms/upload/packages/otf2/otf2-$OTF2_VERSION.tar.gz |& tee -a $LOG_FILE
  tar -xzf otf2-$OTF2_VERSION.tar.gz |& tee -a $LOG_FILE
  cd otf2-$OTF2_VERSION
  ./configure CC=clang CXX=clang++ --prefix=$OTF2_DIR/$OTF2_VERSION --enable-shared |& tee -a $LOG_FILE
  make -j $USE_PROCS |& tee -a $LOG_FILE
  make install |& tee -a $LOG_FILE
  cd ..
  rm -rf otf2-$OTF2_VERSION
  rm otf2-$OTF2_VERSION.tar.gz
fi
echo "Using OTF2 $OTF2_VERSION in $OTF2_DIR" |& tee -a $LOG_FILE

# Set up HPX build
HPX_REPO=${HPX_REPO:-"$HOME/hpx"}
echo "Using HPX repository at $HPX_REPO" |& tee -a $LOG_FILE
# Clone HPX if needed
if [ ! -d $HPX_REPO ]
then
  git clone https://github.com/STEllAR-GROUP/hpx.git $HPX_REPO |& tee -a $LOG_FILE
fi
# Set the state of the hpx repository to what it was on the requested date
cd $HPX_REPO
HPX_HASH=`git rev-list -1 --before=@$BUILD_DATE master` |& tee -a $LOG_FILE
git checkout $HPX_HASH |& tee -a $LOG_FILE
# Create an HPX build directory for this timestamp (don't pollute the repo directory with multiple builds)
if [ -d $TARGET_DIR/hpx ]
then
  rm -rf $TARGET_DIR/hpx
fi
mkdir $TARGET_DIR/hpx
cd $TARGET_DIR/hpx
# Build HPX
cmake $HPX_PARAMS $HPX_REPO |& tee -a $LOG_FILE
make -j $USE_PROCS -l $USE_PROCS |& tee -a $LOG_FILE
echo "HPX build completed" |& tee -a $LOG_FILE

# Set up / build blaze
BLAZE_REPO=${BLAZE_REPO:-"$HOME/blaze"}
echo "Using Blaze repository at $BLAZE_REPO" |& tee -a $LOG_FILE
# Clone blaze if needed
if [ ! -d $BLAZE_REPO ]
then
  git clone https://bitbucket.org/blaze-lib/blaze/src/master $BLAZE_REPO |& tee -a $LOG_FILE
fi
# Set the state of the blaze repository to what it was on the requested date
cd $BLAZE_REPO
BLAZE_HASH=`git rev-list -1 --before=@$BUILD_DATE master` |& tee -a $LOG_FILE
git checkout $BLAZE_HASH |& tee -a $LOG_FILE
# Create a blaze build directory for this timestamp (don't pollute the repo directory with multiple builds)
if [ -d $TARGET_DIR/blaze ]
then
  rm -rf $TARGET_DIR/blaze
fi
mkdir $TARGET_DIR/blaze
cd $TARGET_DIR/blaze
# Build blaze
cmake $BLAZE_PARAMS $BLAZE_REPO |& tee -a $LOG_FILE
make -j $USE_PROCS -l $USE_PROCS |& tee -a $LOG_FILE
echo "Blaze build completed" |& tee -a $LOG_FILE

# Set up / build blaze tensor
BLAZE_TENSOR_REPO=${BLAZE_REPO:-"$HOME/blaze"}
echo "Using Blaze tensor repository at $BLAZE_TENSOR_REPO" |& tee -a $LOG_FILE
# Clone blaze if needed
if [ ! -d $BLAZE_TENSOR_REPO ]
then
  git clone https://github.com/STEllAR-GROUP/blaze_tensor $BLAZE_TENSOR_REPO |& tee -a $LOG_FILE
fi
# Set the state of the blaze repository to what it was on the requested date
cd $BLAZE_TENSOR_REPO
BLAZE_TENSOR_HASH=`git rev-list -1 --before=@$BUILD_DATE master` |& tee -a $LOG_FILE
git checkout $BLAZE_TENSOR_HASH |& tee -a $LOG_FILE
# Create a blaze build directory for this timestamp (don't pollute the repo directory with multiple builds)
if [ -d $TARGET_DIR/blaze_tensor ]
then
  rm -rf $TARGET_DIR/blaze_tensor
fi
mkdir $TARGET_DIR/blaze_tensor
cd $TARGET_DIR/blaze_tensor
# Build blaze
cmake $BLAZE_TENSOR_PARAMS $BLAZE_TENSOR_REPO |& tee -a $LOG_FILE
make -j $USE_PROCS -l $USE_PROCS |& tee -a $LOG_FILE
echo "Blaze tensor build completed" |& tee -a $LOG_FILE

# Set up Phylanx build
PHYLANX_REPO=${PHYLANX_REPO:-"$HOME/phylanx"}
echo "Using Phylanx repository at $PHYLANX_REPO" |& tee -a $LOG_FILE
# Clone Phylanx if needed
if [ ! -d $PHYLANX_REPO ]
then
  git clone https://github.com/STEllAR-GROUP/phylanx.git $PHYLANX_REPO |& tee -a $LOG_FILE
fi
# Set the state of the phylanx repository to what it was on the requested date
cd $PHYLANX_REPO
PHYLANX_HASH=`git rev-list -1 --before=@$BUILD_DATE master` |& tee -a $LOG_FILE
git checkout $PHYLANX_HASH |& tee -a $LOG_FILE
# Create an Phylanx build directory for this timestamp (don't pollute the repo directory with multiple builds)
if [ -d $TARGET_DIR/phylanx ]
then
  rm -rf $TARGET_DIR/phylanx
fi
mkdir $TARGET_DIR/phylanx
cd $TARGET_DIR/phylanx
# Build Phylanx
cmake $PHYLANX_PARAMS $PHYLANX_REPO |& tee -a $LOG_FILE
make -j $USE_PROCS -l $USE_PROCS |& tee -a $LOG_FILE
echo "Phylanx build completed" |& tee -a $LOG_FILE

# Copy scripts that we want to run
cp $PHYLANX_REPO/examples/algorithms/als/als.physl $TARGET_DIR/als.physl
cp $PHYLANX_REPO/examples/algorithms/kmeans/kmeans.physl $TARGET_DIR/kmeans.physl
