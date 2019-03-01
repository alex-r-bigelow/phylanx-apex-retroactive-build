export APEX_OTF2=1

cd "$( dirname "${BASH_SOURCE[0]}" )"

for NUMBER in 10 100 1000 10000
do
  echo "Running n=$NUMBER"
  rm -rf factorial$NUMBER
  mkdir factorial$NUMBER
  cd factorial$NUMBER
  srun -n 1 $TARGET_DIR/phylanx/bin/physl -p --performance $NUMBER |& tee output.txt
  cd ..
done

echo "Finished"
