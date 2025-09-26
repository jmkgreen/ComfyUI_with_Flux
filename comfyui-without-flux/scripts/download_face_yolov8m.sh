#!/usr/bin/env bash

# This script downloads the face_yolov8m.pt model file from Hugging Face
# and saves it to the specified directory.
# It uses wget with quiet mode and shows progress during the download.

# This model is used for face detection in ComfyUI.

mkdir -p /workspace/ComfyUI/models/ultralytics/bbox && \
    wget -q --show-progress "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt?download=true" -O /workspace/ComfyUI/models/ultralytics/bbox/face_yolov8m.pt
