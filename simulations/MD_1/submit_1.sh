#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="MD-LBS"
#SBATCH --get-user-env
#SBATCH --output=_scheduler-stdout.txt
#SBATCH --error=_scheduler-stderr.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=04:00:00

#SBATCH -A s1073
#SBATCH -C gpu

module load daint-gpu/21.09
module load intel
module load cudatoolkit/11.2.0_3.39-2.1__gf93aa1c
module load PyTorch/1.10.1-CrayGNU-21.09
module load TensorFlow/2.4.0-CrayGNU-21.09

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


'srun' '-u' '-n' '1' '--hint=nomultithread' '--unbuffered' '/users/tthakur/git/lammps/build/lmp' '-in' 'iteration_1.in'



 

 
