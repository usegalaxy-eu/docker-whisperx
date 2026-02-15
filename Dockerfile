ARG UV_VERSION=0.9.28
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

COPY --from=uv /uv /uvx /usr/local/bin/

ENV UV_SYSTEM_PYTHON=1 \
    UV_NO_CACHE=1 \
    UV_HTTP_TIMEOUT=300

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ffmpeg \
        libsndfile1 \
        python3 \
    && rm -rf /var/lib/apt/lists/* \
    && uv pip install --system --break-system-packages --no-cache \
        torch~=2.8.0 torchaudio~=2.8.0 \
        --extra-index-url https://download.pytorch.org/whl/cu128 \
    && uv pip install --system --break-system-packages --no-cache whisperx==3.8.1 \
    && rm -rf /root/.cache/ /tmp/* /var/tmp/*

ENTRYPOINT [""]
