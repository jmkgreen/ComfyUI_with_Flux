FROM nvidia/cuda:12.9.1-cudnn-devel-ubuntu22.04 AS comfyui

# RunPod Pods run from a Docker image, thus everything we ship needs to be in this Dockerfile and copied into the image.
# However, for persistence across multiple Pods, we use a volume mounted to /workspace, so anything that needs to be persistent should be in /workspace.
# Thus, we copy scripts to /workspace and run them from there.
# Everything intended for ComfyUI itself should be in /ComfyUI, which is created when we clone the repo, and added to.

ENV PATH="/usr/local/cuda/bin:${PATH}"

ARG DEBIAN_FRONTEND=noninteractive

# Install all required system packages in a single layer with cleanup
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv \
        openssh-server openssh-client \
        git git-lfs wget vim zip unzip curl \
        nginx g++ libcairo2-dev \
        libgl1-mesa-glx libglib2.0-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# nginx: Copy the 'default' configuration file to the appropriate location
COPY default /etc/nginx/sites-available/default

COPY --chmod=755 scripts/ /scripts/

COPY --chmod=644 workflows/ /ComfyUI/user/default/workflows/
COPY --chmod=644 comfy.settings.json /ComfyUI/user/default/comfy.settings.json
COPY --chmod=644 character_sheet_example.png example_photo.png example_photo_small.png example_pose.png example2.png driving_video.mp4 /ComfyUI/input/

WORKDIR /workspace

# Expose ComfyUI port
EXPOSE 8188

# Download and move flux_dev_example.png
RUN wget -nv \
  --tries=3 \
  --waitretry=5 \
  --timeout=20 \
  -O /ComfyUI/flux_dev_example.png \
  "https://raw.githubusercontent.com/comfyanonymous/ComfyUI_examples/master/flux/flux_dev_example.png"

# This is a hacky way to change the default workflow on startup, but it works
COPY --chmod=644 defaultGraph.json /defaultGraph.json
COPY --chmod=755 replaceDefaultGraph.py /replaceDefaultGraph.py
# Run the Python script
RUN python3 /replaceDefaultGraph.py

# Overwrite the default.json file in ComfyUI/web/templates for the new UI
COPY --chmod=644 defaultGraph.json /ComfyUI/web/templates/default.json

FROM comfyui AS with_jupyter
# Expose JupyterLab port
EXPOSE 8888

FROM with_jupyter AS final

# copy default train_lora.yaml file
COPY --chmod=644 ai-toolkit/train_lora.yaml /ai-toolkit/config/train_lora.yaml
COPY --chmod=755 ai-toolkit/caption_images.py /caption_images.py
EXPOSE 7860

# make the directory ready for model checkpoints
RUN mkdir -p /ComfyUI/models/checkpoints
#    wget -q --show-progress "https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly-fp16.safetensors?download=true" -O /ComfyUI/models/checkpoints/v1-5-pruned-emaonly-fp16.safetensors

CMD [ "/scripts/boot.sh" ]
