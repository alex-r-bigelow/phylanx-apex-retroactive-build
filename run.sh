export APEX_OTF2=1
export APEX_CSV_OUTPUT=1
export APEX_TASKGRAPH_OUTPUT=1

cd `dirname $0`

for THREADS in 8 16 24 32 36
do
  mkdir run$THREADS
  cd run$THREADS
  srun -n 1 ../phylanx/bin/als_csv_instrumented \
    -t $THREADS \
    --data_csv=/phylanx-data/CSV/MovieLens_20m.csv \
    --hpx:bind=balanced \
    --hpx:numa-sensitive \
    --iterations=1 \
    --f=40 \
    --row_stop=700 \
    --col_stop=20000 >stdout.txt 2>stderr.txt
  cd ..
done
