export APEX_OTF2=1

cd "$( dirname "${BASH_SOURCE[0]}" )"

DATA_CSV=${1:-$HOME/MovieLens.csv}

rm -rf als_small
mkdir als_small
cd als_small

srun -n 1 $TARGET_DIR/phylanx/bin/physl -p --performance als.physl \
  $DATA_CSV \
  700 \
  20000 \
  0.1 \
  3 \
  5 \
  40 \
  True |& tee output.txt
cd ..

echo "Finished"
