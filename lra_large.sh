export APEX_OTF2=1

cd "$( dirname "${BASH_SOURCE[0]}" )"

for THREADS in 1 2 4 8 16 24 32 36
do
  echo "Running with $THREADS threads"
  rm -rf run$THREADS
  mkdir run$THREADS
  cd run$THREADS
  srun -n 1 $TARGET_DIR/phylanx/bin/lra_csv_instrumented \
    -t $THREADS \
    --data_csv=/phylanx-data/CSV/10kx10k.csv \
    --hpx:bind=balanced \
    --hpx:numa-sensitive \
    --n=5000 \
    --row_stop=5000 \
    --col_stop=5000 \
    --instrument |& tee output.txt
  cd ..
done

echo "Finished"
