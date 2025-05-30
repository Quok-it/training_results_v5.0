## Steps to launch training

### QuantaGrid D74H-7U

Launch configuration and system-specific hyperparameters for the QuantaGrid D74H-7U
submission are in the `../<implementation>/pytorch/config_D74H-7U.sh` script.

For training, we use Slurm with the Pyxis extension, and Slurm's MPI support to run our container.

Steps required to launch training on QuantaGrid D74H-7U.

1. Build the docker container and push to a docker registry

```
cd ../pytorch
docker build --pull -t <docker/registry:benchmark-tag> .
docker push <docker/registry:benchmark-tag>
```

2. Transfer the docker image to enroot container image

```
enroot import -o <path_to_enroot_image_name>.sqsh dockerd://<docker/registry:benchmark-tag>
```

3. Launch the training
```
export DATA_DIR="<path/to/dataset>"
export CHECKPOINTS="<path/to/checkpoint>"
export NEMOLOGS="<path/to/nemologs/dir>"
export LOGDIR="<path/to/output/dir>"
export CONT="<path_to_enroot_image_name>.sqsh"
source config_D74H-7U.sh
NEXP=10 sbatch --gpus=${DGXNGPU} -N ${DGXNNODES} run.sub

