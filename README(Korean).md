# Yonsei AI Data Center Slurm 사용법

## 1. Anaconda 설치
```
wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
(You can check new version in https://repo.anaconda.com/archive)

bash Anaconda3-2020.02-Linux-x86_64.sh
cd YOUR_PATH_ANACONDA/bin
./conda init bash
source ~/.bashrc
```

## 2. 코드 실행
1. Anaconda Environment 환경을 생성하고 필요한 패키지를 설치한다.
    - pytorch 설치 방법([사이트](https://pytorch.org/get-started/locally/) 참조, Stable 혹은 LTS version / Linux / Conda 혹은 Pip / Python / CUDA version 맞춰서 선택)
    ```
    pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113
    ```
2. 파이썬 코드를 작성한다. (예시 code.py)
    - `torch.cuda.is_available()`: GPU 사용가능 여부 확인
    - `device = torch.device(cuda)` and `[something].to(device)`: GPU에 Pytorch model이 돌아가도록 하는 명령어
3. 코드를 실행시킬 Shell Script을 작성
    ```
    #!/bin/bash
    #SBATCH -J example <- [Job 이름]
    #SBATCH --gres=gpu:1 <- [사용할 GPU 개수]
    #SBATCH --output=example.out <- [Output 파일 이름. Stdout에 적히는 모든 것들이 이 파일에 작성됨]
    #SBATCH --time 0-23:00:00 <- [코드를 실행시킬 시간, 최대 3일]
    eval "$(conda shell.bash hook)"
    conda activate base <- [Anaconda Environment]
    python code.py --hidden_size 32  --hidden_layer 3 --batch_size 256 --lr 1e-3 --weight_decay 1e-6
    ```
4. Slurm 명령어로 Queue에 Job 넣고 실행
    - Base Partition and Base Queue에 실행 (`sbatch code.sh`)
    - Base Partition and Big Queue에 실행 (`sbatch -q big_qos code.sh`)
    - Big Partition and Big Queue에 실행 (`sbatch -q big_qos -p big code.sh`)
    - AI 센터의 GPU 서버들은 두개의 Partition으로 나뉘고, Queue Type에 따라서  Job의 특성이 달라짐

5. check your job
    - `squeue` or `squeuelong`: Job 상태 확인 가능
    - `sinfo`: 서버 상태 확인가능(Partition별, GPU 활용가능 여부 확인)
    - `scancel [job number]`: Job 취소
    - 최대로 Queue에 넣을 수 있는 Job의 수는 100개
    - Partition과 Queue 별 차이
        - Base Partition and Base Queue: 최대 활용할 수 있는 GPU수는 4개이다. 이 타입은 높은 우선순위를 보장받고 다른 낮은 우선순위의 (Base Partition and Big Queue) Job을 preemption할 수 있어서, AI센터가 붐비는 경우에 GPU를 차지할 확률이 커진다는 장점이 있다.
        - Base Partition and Big Queue: 최대 활용할 수 있는 GPU 수에 제한이 없고 자원이 남아있다면 얼마든지 사용할 수 있다. 하지만, (Base Partition and Base Queue) Job에 의해 Preemption 될 수 있다는 단점이 있다. 중요한 점은 한번 중단된 job은 재시작을 위해 대기하는 것이 아니라 취소된다는 점이다.
        - Big Partition and Big Queue: 마찬가지로 GPU개수에 제한이 없다. 또한, 이 곳에 할당된 job은 Preemption 되지 않는다. 다른 Job의 사용이 끝나서 GPU가 활용가능하고 다른 job들보다 우선순위가 높을때, GPU를 차지할 수 있다.
         