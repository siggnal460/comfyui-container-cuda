FROM docker.io/pytorch/pytorch:2.9.1-cuda13.0-cudnn9-runtime

LABEL version="3.1" maintainer="siggnal460 <siggnal@proton.me>"

LABEL org.opencontainers.image.description "ComfyUI 0.7.0, ComfyUI-Manager 4.0.4, pytorch 2.9.1, CUDA 13.0"

ENV COMFYUI_ARGS=""

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
    git -c advice.detachedHead=false checkout tags/v0.7.0

RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git /opt/comfyui-manager && \
    cd /opt/comfyui-manager && \
    git -c advice.detachedHead=false checkout tags/4.0.4

RUN pip install --root-user-action=ignore \
    --requirement /app/requirements.txt \
    --requirement /opt/comfyui-manager/requirements.txt

WORKDIR /app

EXPOSE 8188

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/usr/bin/bash", "/entrypoint.sh"]
