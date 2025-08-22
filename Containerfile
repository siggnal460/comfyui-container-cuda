FROM docker.io/pytorch/pytorch:2.8.0-cuda12.9-cudnn9-runtime

LABEL version="2.1" maintainer="siggnal460 <siggnal@proton.me>"

LABEL org.opencontainers.image.description "ComfyUI 0.3.51, ComfyUI-Manager 3.35, pytorch 2.8.0, CUDA 12.9"

ENV COMFYUI_ARGS=""

RUN apt update --assume-yes && \
    apt install --assume-yes \
        git \
    	sudo \
        libgl1-mesa-glx \
        libglib2.0-0 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app && \
    cd /app && \
    git -c advice.detachedHead=false checkout tags/v0.3.51

RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git /opt/comfyui-manager && \
    cd /opt/comfyui-manager && \
    git -c advice.detachedHead=false checkout tags/3.35

RUN pip install --root-user-action=ignore \
    --requirement /app/requirements.txt \
    --requirement /opt/comfyui-manager/requirements.txt

WORKDIR /app

EXPOSE 8188

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/usr/bin/bash", "/entrypoint.sh"]
