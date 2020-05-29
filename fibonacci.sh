export APEX_OTF2=1

cd "$( dirname "${BASH_SOURCE[0]}" )"

for NUMBER in 10 100 1000 10000 100000
do
  echo "Running n=$NUMBER"
  rm -rf fibonacci$NUMBER
  mkdir fibonacci$NUMBER
  cd fibonacci$NUMBER
  srun -n 1 $TARGET_DIR/phylanx/bin/physl -p --performance $TARGET_DIR/fibonacci.physl $NUMBER |& tee output.txt
  cd ..
done

echo "Finished"
