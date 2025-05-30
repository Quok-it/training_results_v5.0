## Steps to launch training

### tyche_ngpu64_ngc25.04_pytorch

Launch configuration and system-specific hyperparameters for the
tyche_ngpu64_ngc25.04_pytorch submission are in the
`benchmarks/bert/implementations/tyche_ngpu64_ngc25.04_pytorch/config_GB200_16x4x36x1_pack.sh` script.

Steps required to launch training for tyche_ngpu64_ngc25.04_pytorch.  The sbatch
script assumes a cluster running Slurm with the Pyxis containerization plugin.

1. Build the docker container and push to a docker registry

```
docker build --pull -t <docker/registry:benchmark-tag> .
docker push <docker/registry:benchmark-tag>
```

2. Launch the training
```
source config_GB200_16x4x36x1_pack.sh
CONT=<docker/registry:benchmark-tag> DATADIR=<path/to/data/dir> LOGDIR=<path/to/output/dir> sbatch -N ${DGXNNODES} -t ${WALLTIME} run.sub
```
