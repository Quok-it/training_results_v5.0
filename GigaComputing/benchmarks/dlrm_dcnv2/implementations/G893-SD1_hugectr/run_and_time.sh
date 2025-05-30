#!/bin/bash

cd ../hugectr
export CONT=./nvdlfwea+mlperftv50+dlrm_dcnv2-amd+.sqsh
source config_G893-SD1_1x8x6912.sh
export DATADIR=/path/to/datadir
export DATADIR_VAL=/path/to/datadir_val
export MODEL=/path/to/model
export LOGDIR=/path/to/logdir
export MLPERF_SUBMISSION_ORG=GigaComputing
export MLPERF_SUBMISSION_PLATFORM=G893-SD1

sbatch -N $DGXNNODES -t $WALLTIME run.sub
