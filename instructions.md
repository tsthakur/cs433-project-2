# Instructions for cluster

## Install conda on piz-daint 
- This is a nvidia gpu cluster with Intel® Xeon® E5-2690 v3 @ 2.60GHz (12 cores, 64GB RAM) and NVIDIA® Tesla® P100 16GB. Refer to this link - https://www.cscs.ch/computers/piz-daint
```
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash
```

## Install a conda environment
- A simple emoty python environment v3.10 as that is the most stable version with which nequip was written, so to avoid any breaking, we use it
```
conda create --name=nequip python=3.10 pytest
conda activate nequip
```

## Load correct modules

```
module load daint-gpu/21.09
module load cudatoolkit/11.2.0_3.39-2.1__gf93aa1c
module load PyTorch/1.10.1-CrayGNU-21.09 

```

## Install nequip
```
git clone https://github.com/mir-group/nequip.git
cd nequip
~/miniconda3/envs/nequip/bin/pip install -e .
```

# Instructions for personal machine

- On personal machine, might be worthwhile to use a slightly modified project 1 environment for testing
```
conda env create --file=environment.yml --name=project2
conda activate project2
```

## Install latest pytorch version that can be used by nequip

- without GPU support
```
conda install pytorch==1.11.0 torchvision==0.12.0 torchaudio==0.11.0 cpuonly -c pytorch
```

- For GPU support
   - optionally install CUDA
   - CUDA v11.3 to match cudatoolkit 11.3
```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
sudo apt-get update
sudo apt-get -y install cuda
```

- Now install pytorch, torhcvision and audio are not necessary for nequip, and this conda version of cudatoolkit it usually not sufficient, so we need to install cuda with apt with matching version 
```
conda install pytorch==1.11.0 torchvision==0.12.0 torchaudio==0.11.0 cudatoolkit=11.3 -c pytorch
```

### Optionally install wandb to keep track of different iterations
```
create an account on wandb.ai
pip install wandb
wandb login
```

## Install nequip as editable in case we want to change something in the code
```
git clone https://github.com/mir-group/nequip.git
cd nequip
pip install . -e
```
# Common instructions

### Optionally test the install with
```
nequip-train configs/minimal.yaml
pytest tests/htop
```

## Install the supported version of LAMMPS with the nequip pair potential
```
git clone -b stable_29Sep2021_update2 --depth 1 git@github.com:lammps/lammp
git clone git@github.com:mir-group/pair_nequip
cd pair_nequip
./patch_lammps.sh /path/to/lammps/
cd lammps
mkdir build
cd build
cmake ../cmake -DCMAKE_PREFIX_PATH=`python -c 'import torch;print(torch.utils.cmake_prefix_path)'` -DMKL_INCLUDE_DIR="$CONDA_PREFIX/include"
```

### To use LAMMPS
 - run the `lammps/build/lmp` 