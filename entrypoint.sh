#!/usr/bin/env bash

emphatic_echo() {
  BOLD="\033[1m"
  RESET="\033[0m"

  echo -e "${BOLD}$1${RESET}"
}

## CREATE MODEL DIRS
emphatic_echo "Creating directories for models..."
MODEL_DIRECTORIES=(
  "checkpoints"
  "clip"
  "clip_vision"
  "configs"
  "controlnet"
  "diffusers"
  "diffusion_models"
  "embeddings"
  "gligen"
  "hypernetworks"
  "loras"
  "photomaker"
  "style_models"
  "text_encoders"
  "unet"
  "upscale_models"
  "vae"
  "vae_approx"
)
for MODEL_DIRECTORY in ${MODEL_DIRECTORIES[@]}; do
  mkdir -p /app/models/$MODEL_DIRECTORY
done

## SYMLINK COMFYUI-MANAGER
emphatic_echo "Creating symlink for ComfyUI Manager..."
rm --force /app/custom_nodes/ComfyUI-Manager
ln -fs \
  /opt/comfyui-manager \
  /app/custom_nodes/ComfyUI-Manager

## INSTALL CUSTOM NODE DEPENDENCIES
emphatic_echo "Installing requirements for custom nodes..."
for custom_node_directory in /app/custom_nodes/*; do
  if [ "$custom_node_directory" != "/app/custom_nodes/ComfyUI-Manager" ]; then
    if [ -f "$custom_node_directory/requirements.txt" ]; then
      custom_node_name=${custom_node_directory##*/}
      custom_node_name=${custom_node_name//[-_]/ }
      emphatic_echo "Installing requirements for $custom_node_name..."
      pip install --root-user-action=ignore --requirement "$custom_node_directory/requirements.txt" 2> >(while read line; do echo -e "\e[31m$line\e[0m"; done)
    fi
  fi
done

## RUN CONTAINER
if [[ ! -z "$COMFYUI_ARGS" ]]; then
  emphatic_echo "Running with these extra arguments: ${COMFYUI_ARGS}"
fi

if [ -z "$PUID" ] || [ -z "$PGID" ]; then
  emphatic_echo "Running container as UID $UID..."
  if [[ -z "$COMFYUI_ARGS" ]]; then
    exec "$@"
  else
    exec /opt/conda/bin/python main.py --listen 0.0.0.0 --port 8188 --disable-auto-launch "${COMFYUI_ARGS}"
  fi
else
  emphatic_echo "Creating non-root user..."
  getent group $PGID >/dev/null 2>&1 || groupadd --gid $PGID comfyui-user
  id -u $PUID >/dev/null 2>&1 || useradd --uid $PUID --gid $PGID --create-home comfyui-user
  chown --recursive $PUID:$PGID /app
  chown --recursive $PUID:$PGID /opt/comfyui-manager
  export PATH=$PATH:/home/comfyui-user/.local/bin

  emphatic_echo "Running container as UID $PUID and GID $PGID..."
  if [[ -z "$COMFYUI_ARGS" ]]; then
    sudo --set-home --preserve-env=PATH --user \#$PUID "$@"
  else
    sudo --set-home --preserve-env=PATH --user \#$PUID /opt/conda/bin/python main.py --listen 0.0.0.0 --port 8188 --disable-auto-launch "${COMFYUI_ARGS}"
  fi
fi
