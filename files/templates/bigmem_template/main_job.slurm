#!/bin/bash

#SBATCH --job-name=default_himem_job
#SBATCH --output=default_himem_job-%j.out

#SBATCH --partition=broadwell_himem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=30G

echo "Hello World" 

