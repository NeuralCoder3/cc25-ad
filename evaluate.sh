#!/bin/bash

set -e

SCRIPT_PATH=$(dirname $(realpath $0))

export PATH=${SCRIPT_PATH}/install/bin:$PATH
export LD_LIBRARY_PATH=${SCRIPT_PATH}/install/lib:$LD_LIBRARY_PATH

mkdir -p ${SCRIPT_PATH}/output

echo "Compute AD Complexity"
# run the metrix.sh script
cd ${SCRIPT_PATH}/metrix
./metrix.sh | tee ${SCRIPT_PATH}/output/metrix.txt

echo "Run GMM benchmarks"
cd ${SCRIPT_PATH}/
mkdir -p ${SCRIPT_PATH}/output/autodiff/gmm
sudo docker run -ti -v "$(pwd)/output/autodiff/gmm:/output" -e FOLDERS="10k_small" fodinabor/mimir-ad-bench:gmm
python3 scripts/plot_gmm.py
echo "GMM results are saved in output/autodiff"

echo "Running remaining AD benchmarks"
cd ${SCRIPT_PATH}/
./run.sh
cd ${SCRIPT_PATH}/
cp ${SCRIPT_PATH}/output.txt ${SCRIPT_PATH}/output/adbench.txt

echo "Done."
echo "You can find the results in the output directory."
