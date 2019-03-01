export APEX_OTF2=1

cd "$( dirname "${BASH_SOURCE[0]}" )"

for NUMBER in 3 6 9
do
  echo "Running k=$NUMBER"
  rm -rf kmeans$NUMBER
  mkdir kmeans$NUMBER
  cd kmeans$NUMBER
  srun -n 1 $TARGET_DIR/phylanx/bin/physl -p --performance $TARGET_DIR/kmeans.physl 10000 $NUMBER 5 |& tee output.txt
  cd ..
done

echo "Finished"
