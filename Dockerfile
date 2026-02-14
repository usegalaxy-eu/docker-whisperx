FROM  nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        libsndfile1 \
        python3-pip \
        python3 \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --upgrade pip

RUN pip3 install --no-cache-dir \
    torch torchaudio torchvision \
    --extra-index-url https://download.pytorch.org/whl/cu121

RUN pip3 install --no-cache-dir whisperx==3.8.1 && \
    rm -rf /root/.cache/ && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

ENTRYPOINT [""]
