#!/usr/bin/env bash
echo "Installing ComfyUI to /workspace/ComfyUI"
source /workspace/venv/bin/activate
cd /workspace && \
    git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd ComfyUI && \
    pip3 install -r requirements.txt &&
    echo "ComfyUI installed to /workspace/ComfyUI"


echo "Installing custom nodes"
cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    git clone https://github.com/MadiatorLabs/ComfyUI-RunpodDirect.git && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack && \
    git clone https://github.com/rgthree/rgthree-comfy.git && \
    git clone https://github.com/yolain/ComfyUI-Easy-Use && \
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && \
    git clone https://github.com/ShammiG/ComfyUI-Simple_Readable_Metadata-SG && \
    git clone https://github.com/kijai/ComfyUI-KJNodes && \
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper && \
    git clone https://github.com/VraethrDalkr/ComfyUI-TripleKSampler && \
    cd /workspace/ComfyUI && \
    mkdir pysssss-workflows
echo "Custom nodes installed"