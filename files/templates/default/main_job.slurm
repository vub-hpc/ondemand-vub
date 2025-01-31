#!/bin/bash

#SBATCH --job-name=default_cpu_job
#SBATCH --output=default_himem_job-%j.out

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00

echo "Hello World" 

