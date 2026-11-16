ARG UV_VERSION=0.9.28
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

COPY --from=uv /uv /uvx /usr/local/bin/

ENV UV_SYSTEM_PYTHON=1 \
    UV_NO_CACHE=1 \
    UV_HTTP_TIMEOUT=300

# --exclude-newer (the 3.8.6 release date): WhisperX's dependencies resolve as in the 3.8.6
# image. It can't be used on the torch install (uv finds no solution on the PyTorch index),
# so packages that come with torch from that index (e.g. numpy) are not frozen.
# NLTK punkt_tab (WhisperX alignment) lives in the image, root-owned in a default NLTK
# path: NLTK 3.10 only reads data owned by the job user or root that no one else can
# write to, which a shared model folder or an NFS job directory often isn't.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ffmpeg \
        libsndfile1 \
        libpython3.12 \
        python3 \
    && rm -rf /var/lib/apt/lists/* \
    && uv pip install --system --break-system-packages --no-cache \
        torch~=2.8.0 torchaudio~=2.8.0 torchvision~=0.23.0 \
        --extra-index-url https://download.pytorch.org/whl/cu128 \
    && uv pip install --system --break-system-packages --no-cache \
        --exclude-newer 2026-11-04T17:36:26Z \
        whisperx==3.8.6 \
        torchcodec==0.7.* \
    && python3 -c "import nltk; assert nltk.download('punkt_tab', download_dir='/usr/share/nltk_data', raise_on_error=True)" \
    && setpriv --reuid=65534 --regid=65534 --clear-groups \
        python3 -c "from nltk.tokenize.punkt import PunktTokenizer; PunktTokenizer('english'); PunktTokenizer('german')" \
    && python3 -c "import importlib.metadata as m, torch, torchaudio, whisperx; assert torch.__version__.startswith('2.8.'), torch.__version__; assert torchaudio.__version__.startswith('2.8.'), torchaudio.__version__; assert m.version('whisperx') == '3.8.6'; assert m.version('torchcodec').startswith('0.7.') " \
    && python3 -c "from torchcodec._core import ops; ops.load_torchcodec_shared_libraries()" \
    && whisperx --help >/dev/null \
    && ffmpeg -hide_banner -version >/dev/null \
    && rm -rf /root/.cache/ /tmp/* /var/tmp/*

ENTRYPOINT [""]
