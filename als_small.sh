export APEX_OTF2=1

cd "$( dirname "${BASH_SOURCE[0]}" )"

DATA_CSV=${1:-$HOME/MovieLens.csv}

rm -rf test_run
mkdir test_run
cd test_run

srun -n 1 $TARGET_DIR/phylanx/bin/als_csv_instrumented \
  -t 2 \
  --data_csv=$DATA_CSV \
  --instrument |& tee output.txt
cd ..

echo "Finished"