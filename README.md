# comfyui-container-cuda

A simple ComfyUI and ComfyUI-Manager container.

> [!TIP]
> Custom node compatability (while generally good) is not guaranteed to work with this container. If you run into issue, best you can try is to switch to the custom node's "nightly" branch if it has one. Beware the "Try Fix" button in ComfyUI-Manager, it *can* work but it may also overwrite some packages with older versions and break things.

## Installation

Podman is used with these examples as that is what I use. I don't imagine you would need to make many tweaks (if at all) to use these examples with Docker, however.

> [!IMPORTANT]
> Note for 3.1.2: While preferably we would listen on broadcast in the container and allow port mappings, we have switched to `network="host"`. This is due to a new Comfyui-Manager quirk which forbids installing custom nodes when ComfyUI listens on an address other than loopback.

> [!IMPORTANT]
> Because Python dependencies are installed on container start, when installing custom nodes you will probably need to restart the container completely (i.e. `podman restart comfyui`) for it to work. This also means the more custom nodes you have, the longer the startup process will be. This only applies to a container cold start, however, not when doing so from within ComfyUI e.g. with the "Restart" button within ComfyUI-Manager.

### podman-compose

An example compose file is provided in the compose directory. To get a quickstart instance up and running, simply `cd` to the compose directory and (e.g., running podman with podman-compose installed) run `podman-compose up`. This will create all the necessary container volumes within that directory and run the service as UID 1000.

### podman run

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
    --network="host"
    --gpus all \
    ghcr.io/siggnal460/comfyui-container-cuda:latest
```

### Nix OCI Container

Tested on NixOS 25.11 'Xantusia'

```nix
virtualisation.oci-containers.containers = {
  comfyui = {
    image = "ghcr.io/siggnal460/comfyui-container-cuda:latest";
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
    cmd = [
    ];
    extraOptions = [
      "--network='host'"
      "--name=comfyui"
      "--gpus=all"
    ];
  };
};
```

## Environmental Variables

### COMFYUI_ARGS

You can pass additional arguments to ComfyUI's main.py script via this env variable. For example, `COMFYUI_ARGS="--lowvram --preview-method auto"` will run ComfyUI in low-vram mode with preview mode set to auto.

### PUID and PGID

Set PUID and PGID environmental variables to the user running the ComfyUI service, I recommend using a service account for this. If these are not set, the container will be run by the user running the container. If using PUID and PGID, ensure whatever folders you mount in the container with the "volume" flag are accessible to that UID and GID.

## ComfyUI-Manager Defaults

By default, the container uses Security Level "normal", which allows for the installation of custom nodes but disables some features. There is not currently a way to change this behavior.

## Versioning

Major versions of the container follow CUDA and PyTorch. Ensure you use a container version matching your host machines CUDA version.

| Major Version | CUDA Version | PyTorch Version |
| --- | --- | --- |
| 1.x | 12.8 | 2.7.x |
| 2.x | 12.9 | 2.8.x |
| 3.x | 13.0 | 2.9.x |
