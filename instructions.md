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
- A simple empty python environment v3.10 as that is the most stable version with which nequip was written, so to avoid any breaking, we use it
```
conda create --name=nequip python=3.10 pytest
conda activate nequip
```

## Load correct modules

- For piz-daint:

```
module load daint-gpu/21.09
module load intel
module load cudatoolkit/11.2.0_3.39-2.1__gf93aa1c
module load PyTorch/1.10.1-CrayGNU-21.09
module load TensorFlow/2.4.0-CrayGNU-21.09
```
**NOTE**: TensorFlow library load CuDNN which is needed for LAMMPS.

- For PRNMarvel cluster:

```
module load intel
module load intel-mpi
module load intel-mkl
module load cuda/11.3
conda install cudnn -c conda-forge
```
**NOTE**: any CUDA 11.{x>3} is not present, CUDA 12.0 needs to be tested. CUDA installed with conda won't be natively compiled with the architecture in mind, so better to use the CUDA provided, unless the final resutls don't pass sanity check. CuDNN on the other hand can be installed separately with conda.


## Install nequip
```
git clone https://github.com/mir-group/nequip.git
cd nequip
~/miniconda3/envs/nequip/bin/pip install -e .
```

# Instructions for personal machine

- On personal machine, might be worthwhile to use a slightly modified project 1 environment for testing
```
conda create --name=nequip python=3.10 pytest
conda activate nequip
```

## Install latest pytorch version that can be used by nequip

- without GPU support
```
conda install pytorch==1.11.0 cpuonly -c pytorch
```

- For GPU support
   - optionally install CUDA and CuDNN
   - CUDA v11.3 to match cudatoolkit 11.3
```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
sudo apt-get update
sudo apt-get -y install cuda
```

- Now install pytorch, torhcvision and audio are not necessary for nequip.

**NOTE**: the conda version of cudatoolkit it usually not sufficient, so we need to install cuda with apt with matching version following the above protocol if it is not already installed, the apt version needs to be same or _higher_ than the conda version. _But_ on piz-daint the module version is 11.2 compared to conda version of 11.3 and on PRNMarvel the module version is 11.3 compared to conda version of 11.8. Other versions of conda don't work.
```
conda install pytorch==1.11.0 cudatoolkit=11.3 -c pytorch
```

### Optionally install wandb to keep track of different iterations

- create an account on wandb.ai
- install wandb and login
```
pip install wandb
wandb login
```

## Install nequip
```
git clone https://github.com/mir-group/nequip.git
cd nequip
pip install .
```
# Common instructions

### Optionally test the install with
```
nequip-train configs/minimal.yaml
pytest tests/htop
```

## Install the supported version of LAMMPS with the nequip pair potential
```
git clone -b stable_29Sep2021_update2 --depth 1 https://github.com/lammps/lammps.git
git clone https://github.com/mir-group/pair_nequip.git
cd pair_nequip
./patch_lammps.sh /path/to/lammps/
cd lammps
mkdir build
cd build
cmake ../cmake -DCMAKE_PREFIX_PATH=`python -c 'import torch;print(torch.utils.cmake_prefix_path)'` 
make
```

Following additions to `cmake` command may need to be explicitly defined 
```
-DMKL_INCLUDE_DIR="$MKLROOT/include"
-DCUDA_TOOLKIT_ROOT_DIR="$CUDA_HOME"
-DCUDNN_LIBRARY_PATH="/path/to/conda/env/lib"
-DCUDNN_INCLUDE_PATH="/path/to/conda/env/include"
```

### To use LAMMPS
 - run the `lammps/build/lmp` 

**NOTE**: this version of LAMMPS can only be run in serial as nequip potential doesn't support parallel calculation because of its inherent message passing algorythm. For parallel MD simulaion, allegro potential is required, but it is less robust than nequip and is also local, making it less accurate though much more computationally efficient.
