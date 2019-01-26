export APEX_OTF2=1
export APEX_CSV_OUTPUT=1
export APEX_TASKGRAPH_OUTPUT=1

cd "$( dirname "${BASH_SOURCE[0]}" )"

DATA_CSV=${1:-$HOME/MovieLens.csv}

rm -rf test_run
mkdir test_run
cd test_run

srun -n 1 ../phylanx/bin/als_csv_instrumented \
  -t 2 \
  --data_csv=$DATA_CSV
cd ..
