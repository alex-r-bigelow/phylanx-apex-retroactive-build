
set -e

PROCS=$(lscpu | grep CPU.s.: | head -1 | cut -d: -f2)
USE_PROCS=$(($PROCS/2))

LOG_FILE="$TARGET_DIR/log.txt"
touch $LOG_FILE

echo $'\n\n\n#####\nStarting retroactive build for $BUILD_DATE (unix timestamp for $HUMAN_BUILD_DATE)' |& tee -a $LOG_FILE

# Install OTF2 if needed
if [ ! -d $OTF2_DIR ]
then
  mkdir $OTF2_DIR
fi
if [ ! -d $OTF2_DIR/$OTF2_VERSION ]
then
  echo "Installing OTF2 $OTF2_VERSION in $OTF2_DIR" |& tee -a $LOG_FILE
  cd $OTF2_DIR
  wget http://www.vi-hps.org/upload/packages/otf2/otf2-$OTF2_VERSION.tar.gz |& tee -a $LOG_FILE
  tar -xzf otf2-$OTF2_VERSION.tar.gz |& tee -a $LOG_FILE
  cd otf2-$OTF2_VERSION
  ./configure CC=clang CXX=clang++ --prefix=$OTF2_DIR/$OTF2_VERSION --enable-shared |& tee -a $LOG_FILE
  make -j $USE_PROCS |& tee -a $LOG_FILE
  make install |& tee -a $LOG_FILE
  cd ..
  rm -rf otf2-$OTF2_VERSION
  rm otf2-$OTF2_VERSION.tar.gz
fi
echo "Using OTF2 $OTF2_VERSION in $OTF2_DIR\n" |& tee -a $LOG_FILE

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
echo "HPX build completed successfully\n" |& tee -a $LOG_FILE

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
mkdir $TARGET_DIR/hpx
cd $TARGET_DIR/phylanx
# Build Phylanx
cmake $PHYLANX_PARAMS $PHYLANX_REPO |& tee -a $LOG_FILE
make -j $USE_PROCS -l $USE_PROCS |& tee -a $LOG_FILE
echo "Phylanx build completed successfully\n" |& tee -a $LOG_FILE
