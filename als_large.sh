export APEX_OTF2=1

cd "$( dirname "${BASH_SOURCE[0]}" )"

for THREADS in 8 16 24 32 36
do
  echo "Running with $THREADS threads"
  rm -rf als_large$THREADS
  mkdir als_large$THREADS
  cd als_large$THREADS
  srun -n 1 $TARGET_DIR/phylanx/bin/als_csv_instrumented \
    -t $THREADS \
    --data_csv=/phylanx-data/CSV/MovieLens_20m.csv \
    --hpx:bind=balanced \
    --hpx:numa-sensitive \
    --iterations=1 \
    --f=40 \
    --row_stop=700 \
    --col_stop=20000 \
    --instrument |& tee output.txt
  cd ..
done

echo "Finished"
