FROM docker.io/pytorch/pytorch:2.9.1-cuda13.0-cudnn9-runtime

LABEL version="3.4" maintainer="siggnal460 <siggnal@proton.me>"

LABEL org.opencontainers.image.description "ComfyUI 0.27.0, pytorch 2.9.1, CUDA 13.0"

ENV COMFYUI_ARGS=""

ENV TORCH_USE_CUDA_DSA=1

ENV CUDA_LAUNCH_BLOCKING=1

ENV PYTORCH_ALLOC_CONF=expandable_segments:True

RUN apt update --assume-yes && \
    apt install --assume-yes \
        git \
        sudo \
        libgl1-mesa-glx \
        ffmpeg \
        libglib2.0-0 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app && \
    cd /app && \
    git -c advice.detachedHead=false checkout tags/v0.27.0

RUN pip install --root-user-action=ignore \
    --requirement /app/requirements.txt

RUN /opt/conda/bin/python -m pip install --root-user-action=ignore --pre \
    comfyui_manager

RUN /opt/conda/bin/python -m pip install --root-user-action=ignore --pre \
    matrix-nio
    
RUN /opt/conda/bin/python -m pip install --root-user-action=ignore --pre \
    protobuf

RUN /opt/conda/bin/python -m pip install --root-user-action=ignore --pre \
    protobuf

WORKDIR /app

EXPOSE 8188

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/usr/bin/bash", "/entrypoint.sh"]
