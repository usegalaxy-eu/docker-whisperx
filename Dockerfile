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
        libpython3.12 \
        python3 \
    && rm -rf /var/lib/apt/lists/* \
    && uv pip install --system --break-system-packages --no-cache \
        torch~=2.8.0 torchaudio~=2.8.0 \
        --extra-index-url https://download.pytorch.org/whl/cu128 \
    && uv pip install --system --break-system-packages --no-cache \
        whisperx==3.8.1 \
        torchcodec==0.7.* \
    && python3 -c "import importlib.metadata as m, torch, torchaudio, whisperx; assert torch.__version__.startswith('2.8.'), torch.__version__; assert torchaudio.__version__.startswith('2.8.'), torchaudio.__version__; assert m.version('whisperx') == '3.8.1'; assert m.version('torchcodec').startswith('0.7.') " \
    && python3 -c "from torchcodec._core import ops; ops.load_torchcodec_shared_libraries()" \
    && whisperx --help >/dev/null \
    && ffmpeg -hide_banner -version >/dev/null \
    && rm -rf /root/.cache/ /tmp/* /var/tmp/*

ENTRYPOINT [""]
