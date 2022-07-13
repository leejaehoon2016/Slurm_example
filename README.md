# Slurm_example
How to use Slurm in Yonsei AI Data Center

## 1. Install Anaconda
```
wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
(You can check new version in https://repo.anaconda.com/archive)

bash Anaconda3-2020.02-Linux-x86_64.sh
cd YOUR_PATH_ANACONDA/bin
./conda init bash
source ~/.bashrc
```

## 2. Run your code
1. create your anaconda environment and install required packages
2. write a python code (example in code.py)
    - `torch.cuda.is_available()` identifies that gpu is available.
    - `device = torch.device(cuda)` and `[something].to(device)` makes your code run in gpu.
3. write a shell script to run the code.
    ```
    #!/bin/bash
    #SBATCH -J example <- [your job name]
    #SBATCH --gres=gpu:1 <- [the number of gpus you use]
    #SBATCH --output=example.out <- [output file name, everything written in stdout is printed in this file.]
    #SBATCH --time 0-23:00:00 <- [time to run your code, maximum is 3 days]
    eval "$(conda shell.bash hook)"
    conda activate base <- [your anaconda environment]
    python code.py --hidden_size 32  --hidden_layer 3 --batch_size 256 --lr 1e-3 --weight_decay 1e-6
    ```
4. distribute your job in slurm 
    - run in base partition and base queue (`sbatch code.sh`)
    - run in base partition and big queue (`sbatch -q big_qos code.sh`)
    - run in big partition and big queue (`sbatch -q big_qos -p big code.sh`)
    - Gpus in AI server are split into two partition, and the queue type defines a job property.

5. check your job
    - With `squeue` or `squeuelong`, you can check your job status.
    - With `sinfo`, you can check server status (in each partition, how many gpus are available)
    - With `scancel [job number]`, you can cancel your job.
    - The maximum job one person can distribute is 100.
    - Difference in a partition and a queue.
        - base partition and base queue: the maximum number of gpus your job can utilize at once is 4. Since this type has usually a higher priority and only this type can preemt other job which have the lower priority, it is more likely for this job to occupy the gpu first in crowed cases.
        - base partition and big queue: The maximun number is unlimited. However, it can be preempted by the job of base partition and base queue. The important thing is that preempted job is not restarted, but just canceled.
        - big partition and big queue: The maximun number is also unlimited, and jobs in this type are't preempted. When the priorities of other jobs in queue are lower than those of yours and gpus in big partition are available, your job occupy gpus. 