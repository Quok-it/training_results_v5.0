#!/bin/bash

cd ../dgl
source config_G893-SD1_1x8x4096.sh
export CONT=./nvdlfwea+mlperftv50+rgat-amd+.sqsh
export LOGDIR=/path/to/logdir
export DATA_DIR=/path/to/data_dir
export GRAPH_DIR=/path/to/graph_dir
export MLPERF_SUBMISSION_ORG=GigaComputing
export MLPERF_SUBMISSION_PLATFORM=G893-SD1
export FP8_EMBEDDING=1

sbatch -N $DGXNNODES -t $WALLTIME run.sub
