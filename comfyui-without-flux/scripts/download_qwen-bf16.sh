#!/usr/bin/env bash

file="qwen_2.5_vl_7b_fp8_scaled.safetensors"
echo "Downloading ${file} text encoders"
cd /workspace/ComfyUI/models/text_encoders/

url="https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi


file="qwen_image_vae.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/vae/

url="https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

# file="qwen_image_fp8_e4m3fn.safetensors"
# echo "Downloading ${file}"
# cd /workspace/ComfyUI/models/diffusion_models/

# url="https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/diffusion_models/${file}?download=true"

# if [ -f "$file" ]; then
#     echo "$file already exists."
# else
#     echo "Downloading $file"
#     wget -O $file $url --progress=bar:force:noscroll
# fi

file="qwen_image_edit_2509_fp8_e4m3fn.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/diffusion_models/

url="https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi


file="Qwen-Image-Edit-Lightning-4steps-V1.0.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/loras/

url="https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi