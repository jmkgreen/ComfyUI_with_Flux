FROM pytorch/pytorch:2.8.0-cuda12.9-cudnn9-runtime AS comfyui

# RunPod Pods run from a Docker image, thus everything we ship needs to be in this Dockerfile and copied into the image.
# However, for persistence across multiple Pods, we use a volume mounted to /workspace, so anything that needs to be persistent should be in /workspace.
# Thus, we copy scripts to /workspace and run them from there.
# Everything intended for ComfyUI itself should be in /ComfyUI, which is created when we clone the repo, and added to.

ENV PATH="/usr/local/cuda/bin:${PATH}"

ARG DEBIAN_FRONTEND=noninteractive

# Install Python plus openssh, which is our minimum set of required packages.
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openssh-server openssh-client git git-lfs wget vim zip unzip curl nginx g++

# nginx: Copy the 'default' configuration file to the appropriate location
COPY default /etc/nginx/sites-available/default

RUN mkdir /scripts
COPY --chmod=755 scripts/boot.sh /scripts/boot.sh
COPY --chmod=755 scripts/boot-user.sh /scripts/boot-user.sh
COPY --chmod=755 scripts/install-comfyui.sh /scripts/install-comfyui.sh
COPY --chmod=755 scripts/install-sageattention.sh /scripts/install-sageattention.sh
COPY --chmod=755 scripts/install-ai-toolkit.sh /scripts/install-ai-toolkit.sh
COPY --chmod=755 scripts/comfyui-on-workspace.sh /scripts/comfyui-on-workspace.sh
COPY --chmod=755 scripts/ai-toolkit-on-workspace.sh /scripts/ai-toolkit-on-workspace.sh
COPY --chmod=755 scripts/check_files.sh /scripts/check_files.sh

COPY --chmod=644 workflows/ /ComfyUI/user/default/workflows/
COPY --chmod=644 comfy.settings.json /ComfyUI/user/default/comfy.settings.json
COPY --chmod=644 character_sheet_example.png /ComfyUI/input/character_sheet_example.png
COPY --chmod=644 example_photo.png /ComfyUI/input/example_photo.png
COPY --chmod=644 example_photo_small.png /ComfyUI/input/example_photo_small.png
COPY --chmod=644 example_pose.png /ComfyUI/input/example_pose.png
COPY --chmod=644 example2.png /ComfyUI/input/example2.png
COPY --chmod=644 driving_video.mp4 /ComfyUI/input/driving_video.mp4

WORKDIR /workspace

# Expose ComfyUI port
EXPOSE 8188

# Download and move flux_dev_example.png
RUN wget -q "https://github.com/comfyanonymous/ComfyUI_examples/blob/master/flux/flux_dev_example.png" -P /ComfyUI

# For Xlabs-AI/flux-RealismLora and others
RUN apt-get install -y libgl1-mesa-glx libglib2.0-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/XLabs-AI/x-flux-comfyui.git && \
#     cd x-flux-comfyui && \
#     python3 setup.py

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

# # Add some additional custom nodes
# # LDSR Upscale
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/flowtyone/ComfyUI-Flowty-LDSR.git && \
#     cd ComfyUI-Flowty-LDSR && \
#     pip3 install -r requirements.txt

# Add download scripts for additional models
COPY --chmod=755 scripts/download_Controlnet.sh /scripts/download_Controlnet.sh
COPY --chmod=755 scripts/download_fp16.sh /scripts/download_fp16.sh
COPY --chmod=755 scripts/download_LDSR.sh /scripts/download_LDSR.sh
COPY --chmod=755 scripts/download_SUPIR.sh /scripts/download_SUPIR.sh
COPY --chmod=755 scripts/download_Florence-2.sh /scripts/download_Florence-2.sh
COPY --chmod=755 scripts/download_Upscalers.sh /scripts/download_Upscalers.sh
COPY --chmod=755 scripts/download_Outpainting.sh /scripts/download_Outpainting.sh
COPY --chmod=755 scripts/download_Workflows.sh /scripts/download_Workflows.sh
COPY --chmod=755 scripts/update_Workflows.sh /scripts/update_Workflows.sh
COPY --chmod=755 scripts/download_ALL.sh /scripts/download_ALL.sh
COPY --chmod=755 scripts/make_venv.sh /scripts/make_venv.sh
COPY --chmod=755 scripts/download_flux.sh /scripts/download_flux.sh
COPY --chmod=755 scripts/download_wan2.1.sh /scripts/download_wan2.1.sh
COPY --chmod=755 scripts/disable_mixlab.sh /scripts/disable_mixlab.sh

# # SUPIR Upscale
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/kijai/ComfyUI-SUPIR.git && \
#     cd ComfyUI-SUPIR && \
#     pip3 install -r requirements.txt

# # KJNodes
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/kijai/ComfyUI-KJNodes.git && \
#     cd ComfyUI-KJNodes && \
#     pip3 install -r requirements.txt

# # rgthree
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/rgthree/rgthree-comfy.git && \
#     cd rgthree-comfy && \
#     pip3 install -r requirements.txt

# # JPS-Nodes
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/JPS-GER/ComfyUI_JPS-Nodes.git

# # Comfyrol Studio
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git

# # comfy-plasma
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/Jordach/comfy-plasma.git

# # ComfyUI-VideoHelperSuite
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
#     cd ComfyUI-VideoHelperSuite && \
#     pip3 install -r requirements.txt

# # ComfyUI-AdvancedLivePortrait
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/PowerHouseMan/ComfyUI-AdvancedLivePortrait.git && \
#     cd ComfyUI-AdvancedLivePortrait && \
#     pip3 install -r requirements.txt

# # ComfyUI-Impact-Subpack
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
#     cd ComfyUI-Impact-Pack && \
#     pip3 install -r requirements.txt && \
#     python3 install.py

# # ComfyUI-Impact-Subpack
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack && \
#     cd ComfyUI-Impact-Subpack && \
#     pip3 install -r requirements.txt

# make directory and download face_yolov8m.pt
RUN mkdir -p /ComfyUI/models/ultralytics/bbox && \
    wget -q "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt?download=true" -O /ComfyUI/models/ultralytics/bbox/face_yolov8m.pt

# # ComfyUI-Impact-controlnet_aux
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git && \
#     cd comfyui_controlnet_aux && \
#     pip3 install -r requirements.txt

# # ComfyUI-UltimateSDUpscale
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale --recursive

# # ComfyUI-Easy-Use
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/yolain/ComfyUI-Easy-Use.git && \
#     cd ComfyUI-Easy-Use && \
#     pip3 install -r requirements.txt

# # ComfyUI-Florence2
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/kijai/ComfyUI-Florence2.git && \
#     cd ComfyUI-Florence2 && \
#     pip3 install -r requirements.txt && \
#     mkdir /ComfyUI/models/LLM

# # was-node-suite-comfyui
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/WASasquatch/was-node-suite-comfyui.git && \
#     cd was-node-suite-comfyui && \
#     pip3 install -r requirements.txt

# # ComfyUI-Logic
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/theUpsider/ComfyUI-Logic.git

# # ComfyUI_essentials
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/cubiq/ComfyUI_essentials.git && \
#     cd ComfyUI_essentials && \
#     pip3 install -r requirements.txt

# # cg-image-picker
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/chrisgoringe/cg-image-picker.git

# # ComfyUI_LayerStyle
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/chflame163/ComfyUI_LayerStyle.git && \
#     cd ComfyUI_LayerStyle && \
#     pip3 install -r requirements.txt

# # Comfyui-mixlab-nodes
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/shadowcz007/comfyui-mixlab-nodes.git && \
#     cd comfyui-mixlab-nodes && \
#     pip3 install -r requirements.txt

## WARNING this module currently relies on an old numpy and is therefore excluded
# # comfyui-reactor-node
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://codeberg.org/Gourieff/comfyui-reactor-node.git && \
#     cd comfyui-reactor-node && \
#     pip3 install -r requirements.txt

# make the directory and download the swap_model file
RUN mkdir -p /ComfyUI/models/insightface && \
    wget -q "https://huggingface.co/ezioruan/inswapper_128.onnx/resolve/main/inswapper_128.onnx?download=true" -O /ComfyUI/models/insightface/inswapper_128.onnx

# # cg-use-everywhere
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/chrisgoringe/cg-use-everywhere.git

# # ComfyUI-CogVideoXWrapper
# RUN cd /ComfyUI/custom_nodes && \
#     git clone https://github.com/kijai/ComfyUI-CogVideoXWrapper.git && \
#     cd ComfyUI-CogVideoXWrapper && \
#     pip3 install -r requirements.txt


# copy default train_lora.yaml file
COPY --chmod=644 ai-toolkit/train_lora.yaml /ai-toolkit/config/train_lora.yaml
COPY --chmod=755 ai-toolkit/caption_images.py /caption_images.py
EXPOSE 7860

# make the directory ready for model checkpoints
RUN mkdir -p /ComfyUI/models/checkpoints
#    wget -q --show-progress "https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly-fp16.safetensors?download=true" -O /ComfyUI/models/checkpoints/v1-5-pruned-emaonly-fp16.safetensors

CMD [ "/scripts/start.sh" ]
