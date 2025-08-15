# comfyui-container-cuda

A simple ComfyUI and ComfyUI-Manager container based on the latest PyTorch image. Should (mostly) work with the latest NVIDIA GPUs.

> [!WARNING]
> Custom node compatability is not guaranteed to work with this container. If you run into issue, best you can try is to switch to the custom node's "nightly" branch if it has one. Beware the "Try Fix" button in ComfyUI-Manager, it may overwrite some packages with older versions and break things. Because dependencies are installed on container start, the more custom nodes you have the longer the startup process will be. This does not apply, however, when restarting it from within e.g. through ComfyUI-Manager.

## Installation

### COMFYUI_ARGS

You can pass additional arguments to ComfyUI's main.py script via this env variable. For example, `COMFYUI_ARGS="--lowvram --preview-method auto"` will run ComfyUI in low-vram mode with preview mode set to auto.

### PUID and PGID

Set PUID and PGID environmental variables to the user running the ComfyUI service, I recommend using a service account for this. If these are not set, the container will be run by the user running the container. If using PUID and PGID, ensure whatever folders you mount in the container with the "volume" flag are accessible to that PUID and PGID.

## podman-compose

An example Podman compose file is provided.

## podman run

```shell
podman run \
    --name comfyui \
    --env PUID="<desired-uid>" \
    --env PGID="<desired-gid>" \
    --env COMFYUI_ARGS="<desired-arguments>" \
    --volume "</path/to/models/folder>:/app/models:rw" \
    --volume "</path/to/custom_nodes/folder>:/app/custom_nodes:rw" \
    --volume "</path/to/input>:/app/input:rw" \
    --volume "</path/to/output>:/app/output:rw" \
    --volume "</path/to/userdata>:/app/user/default:rw" \
    --publish <desired-port>:8188 \
    --gpus all \
    ghcr.io/siggnal460/comfyui-container-cuda:latest
```

## nix oci-containers

Tested on NixOS 25.05 'Warbler'

```nix
virtualisation.oci-containers.containers = {
  comfyui = {
    image = "ghcr.io/siggnal460/comfyui-container-cuda:latest";
    ports = [ "<desired-port>:8188" ];
    volumes = [
      "</path/to/models/folder>:/app/models:rw"
      "</path/to/input>:/app/input:rw"
      "</path/to/output>:/app/output:rw"
      "</path/to/userdata>:/app/user/default:rw"
      "</path/to/custom_nodes>:/app/custom_nodes:rw"
    ];
    environment = {
      PUID = "<desired-uid>";
      PGID = "<desired-gid>";
      COMFYUI_ARGS = "<desired-arguments>";
    };
    extraOptions = [
      "--name=comfyui"
      "--gpus=all"
    ];
  };
};
```
