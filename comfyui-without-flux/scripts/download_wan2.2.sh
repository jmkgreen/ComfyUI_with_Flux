#!/usr/bin/env bash

echo "Downloading umt5_xxl_fp8_e4m3fn_scaled.safetensors text encoders"
cd /workspace/ComfyUI/models/text_encoders/

file="umt5_xxl_fp8_e4m3fn_scaled.safetensors"
url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi


echo "Downloading wan_2.2_vae.safetensors"
cd /workspace/ComfyUI/models/vae/

file="wan_2.2_vae.safetensors"
url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan2.2_vae.safetensors?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

echo "Downloading wan2.2_i2v_high_noise_14B_fp16.safetensors"
cd /workspace/ComfyUI/models/diffusion_models/

file="wan2.2_i2v_high_noise_14B_fp16.safetensors"
url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

echo "Downloading wan2.2_i2v_low_noise_14B_fp16.safetensors"
cd /workspace/ComfyUI/models/diffusion_models/

file="wan2.2_i2v_low_noise_14B_fp16.safetensors"
url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi


echo "Downloading clip_vision_h.safetensors"
cd /workspace/ComfyUI/models/clip_vision/

file="clip_vision_h.safetensors"
url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

echo "Downloading wan2.2_t2v_high_noise_14B_fp16.safetensors"
cd /workspace/ComfyUI/models/diffusion_models/

file="wan2.2_t2v_high_noise_14B_fp16.safetensors"
url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

echo "Downloading wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors"
cd /workspace/ComfyUI/models/diffusion_models/

file="wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors"
url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi
