FROM docker.io/pytorch/pytorch:2.7.1-cuda12.8-cudnn9-runtime

LABEL version="1.4" maintainer="siggnal460 <siggnal@proton.me>"

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
    git -c advice.detachedHead=false checkout tags/v0.3.41

RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git /opt/comfyui-manager && \
    cd /opt/comfyui-manager && \
    git -c advice.detachedHead=false checkout tags/3.33

RUN pip install --root-user-action=ignore \
    --requirement /app/requirements.txt \
    --requirement /opt/comfyui-manager/requirements.txt

WORKDIR /app

EXPOSE 8188

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/usr/bin/bash", "/entrypoint.sh"]

CMD ["/opt/conda/bin/python", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--disable-auto-launch"]
