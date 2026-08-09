FROM docker.io/pytorch/pytorch:2.13.0-cuda13.0-cudnn9-runtime

LABEL version="3.5" maintainer="siggnal460 <siggnal@proton.me>"

LABEL org.opencontainers.image.description "ComfyUI 0.31.0, pytorch 2.13.0, CUDA 13.0"

ENV COMFYUI_ARGS=""

ENV TORCH_USE_CUDA_DSA=1

ENV CUDA_LAUNCH_BLOCKING=1

ENV PYTORCH_ALLOC_CONF=expandable_segments:True

ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN apt update --assume-yes && \
    apt install --assume-yes \
        git \
        sudo \
        libgl1 \
        libglx-mesa0 \
        ffmpeg \
        libglib2.0-0 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app && \
    cd /app && \
    git -c advice.detachedHead=false checkout tags/v0.31.0

RUN /usr/bin/python3 -m pip install --root-user-action=ignore \
    --no-cache-dir \
    --requirement /app/requirements.txt

RUN /usr/bin/python3 -m pip install --root-user-action=ignore --pre \
    --no-cache-dir \
    comfyui_manager

RUN /usr/bin/python3 -m pip install --root-user-action=ignore --pre \
    --no-cache-dir \
    matrix-nio

RUN /usr/bin/python3 -m pip install --root-user-action=ignore --pre \
    --no-cache-dir \
    protobuf

WORKDIR /app

EXPOSE 8188

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/usr/bin/bash", "/entrypoint.sh"]
