#!/bin/bash

#SBATCH --job-name=template_gpu_job
#SBATCH --output=default_gpu_job-%j.out

#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-gpu=16
#SBATCH --time=01:00:00

echo "Hello World" 

