#!/bin/bash
echo "Installing ComfyUI to /workspace/ComfyUI"
cd /workspace && \
    git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd ComfyUI && \
    pip3 install -r requirements.txt && \
    cd custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && \
    cd /workspace/ComfyUI && \
    mkdir pysssss-workflows
echo "ComfyUI installed to /workspace/ComfyUI"