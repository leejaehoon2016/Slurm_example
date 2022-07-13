#!/bin/bash
#SBATCH -J example
#SBATCH --gres=gpu:1
#SBATCH --output=example.out
#SBATCH --time 0-23:00:00
eval "$(conda shell.bash hook)"
conda activate base
python code.py --hidden_size 32  --hidden_layer 3 --batch_size 256 --lr 1e-3 --weight_decay 1e-6