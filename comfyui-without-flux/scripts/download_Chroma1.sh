#!/usr/bin/env bash

echo "Downloading Chroma1"
cd /workspace/ComfyUI/models/diffusion_models

file="Chroma1-HD-fp8_scaled_rev2.safetensors"
url="https://huggingface.co/silveroxides/Chroma1-HD-fp8-scaled/resolve/main/Chroma1-HD-fp8_scaled_rev2.safetensors"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

echo "Downloading t5xxl_fp8_e4m3fn_scaled.safetensors text encoder"
cd /workspace/ComfyUI/models/text_encoders

file="t5xxl_fp8_e4m3fn_scaled.safetensors"
url="https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi
echo "Chroma1 and text encoder download complete."