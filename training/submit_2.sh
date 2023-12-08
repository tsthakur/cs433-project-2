#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="nequip-LBS"
#SBATCH --get-user-env
#SBATCH --output=_scheduler-stdout.txt
#SBATCH --error=_scheduler-stderr.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=24:00:00

#SBATCH -A s1073
#SBATCH -C gpu

module load daint-gpu/21.09
module load intel
module load cudatoolkit/11.2.0_3.39-2.1__gf93aa1c
module load PyTorch/1.10.1-CrayGNU-21.09

. "/users/tthakur/miniconda3/etc/profile.d/conda.sh"
conda activate nequip

NTASKS_PER_NODE=$((SLURM_NTASKS / SLURM_JOB_NUM_NODES))

if [ $NTASKS_PER_NODE -eq 1 ]; then
    CRAY_CUDA_MPS=0
else
    CRAY_CUDA_MPS=1
fi    

export CRAY_CUDA_MPS=$CRAY_CUDA_MPS
export MPICH_MAX_THREAD_SAFETY=multiple
export MKL_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK


'srun' '-u' '-n' '1' '--hint=nomultithread' '--unbuffered' '/users/tthakur/miniconda3/envs/nequip/bin/nequip-train' 'iteration_2.yaml' 

'srun' '-u' '-n' '1' '--hint=nomultithread' '--unbuffered' '/users/tthakur/miniconda3/envs/nequip/bin/nequip-deploy' 'build' '--train-dir' '/scratch/snx3000/tthakur/cs433_project2/LBS/training/results/iteration_2' 'iteration_2-deployed.pth'


 

 
