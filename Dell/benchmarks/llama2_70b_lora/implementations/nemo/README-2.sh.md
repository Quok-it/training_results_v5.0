#!/bin/bash
cd /tmp
# Install depends
sudo apt install -y slurm-wlm slurm-client munge libslurm-dev
# Create key
sudo dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
sudo chown munge: /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key
munge -n | unmunge
# Setup slurm config
mkdir -p /etc/slurm/
cat > /etc/slurm/slurm.conf << EOF
ClusterName=voltagepark
ControlMachine=$(hostname)
MpiDefault=none
ProctrackType=proctrack/pgid
ReturnToService=2
SlurmctldPort=6817
SlurmdPort=6818
AuthType=auth/munge
StateSaveLocation=/var/spool/slurmctld
SlurmdSpoolDir=/var/spool/slurmd
SwitchType=switch/none
SlurmUser=slurm
NodeName=localhost CPUs=104 Sockets=2 CoresPerSocket=52 ThreadsPerCore=1 Gres=gpu:8 State=UNKNOWN
PartitionName=debug Nodes=localhost Default=YES MaxTime=INFINITE State=UP
SlurmctldLogFile=/var/log/slurmctld.conf
EOF

mkdir -p /var/spool/slurmctld
chown -R slurm:slurm /var/spool/slurmctld

# Enable services
sudo systemctl enable slurmctld slurmd

# Enroot
wget https://github.com/NVIDIA/enroot/releases/download/v3.5.0/enroot_3.5.0-1_amd64.deb
sudo apt install -y ./enroot_3.5.0-1_amd64.deb



# Build pyxis

git clone https://github.com/NVIDIA/pyxis.git
cd pyxis
# changing prefix to /usr
make prefix=/usr
make prefix=/usr install
# change config
sudo ln -sfv /usr/share/pyxis/pyxis.conf /etc/slurm/plugstack.conf.d/pyxis.conf
# Restart service with pyxis enabled
sudo systemctl restart slurmctld slurmd

# Install nvida docker extension
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install the toolkit
sudo apt-get update
sudo apt-get install -y nvidia-docker2 nvidia-cuda-toolkit
sudo apt-get install libpmix-dev openmpi-bin libopenmpi-dev
sudo apt install -y libnvidia-container-tools=1.17.6-1 libnvidia-container1=1.17.6-1 nvidia-container-toolkit=1.17.6-1 nvidia-container-toolkit-base=1.17.6-1 --allow-downgrades

sudo tee /etc/slurm/gres.conf <<EOF
Name=gpu File=/dev/nvidia0,/dev/nvidia1,/dev/nvidia2,/dev/nvidia3,/dev/nvidia4,/dev/nvidia5,/dev/nvidia6,/dev/nvidia7
EOF

docker build -t mlperf-nvidia:llama2_70b_lora-pyt .
docker run -it --rm --gpus all --network=host --ipc=host --volume /dataset:/data mlperf-nvidia:llama2_70b_lora-pyt


# RUN THIS IN THE CONTAINER
python scripts/download_dataset.py --data_dir /data/gov_report
python scripts/download_model.py --model_dir /data/model --max_workers=2
# EXIT CONTAINER


export DATADIR="/dataset/gov_report"  # set your </path/to/dataset>
export MODEL="/dataset/model"  # set your </path/to/dataset>
mkdir -p /var/log/llama-70b-lora
export LOGDIR="/var/log/llama-70b-lora"  # set the place where the output logs will be saved
export CONT="dockerd://mlperf-nvidia:llama2_70b_lora-pyt"
export SLURM_MPI_TYPE=pmi2
source config_XE9680lx8H200-SXM-141GB_1x8x2xtp1pp1cp2.sh

sbatch -N $DGXNNODES -t $WALLTIME run.sub





