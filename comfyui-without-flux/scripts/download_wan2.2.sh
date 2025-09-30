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


file="wan_2.2_vae.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/vae/

url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan2.2_vae.safetensors?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

file="clip_vision_h.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/clip_vision/

url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/clip_vision/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

file="wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/diffusion_models/

url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

file="wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/diffusion_models/

url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

file="wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/diffusion_models/

url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

file="wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/diffusion_models/

url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

file="wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/loras/

url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi

file="wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/diffusion_models/

url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi


file="wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors"
echo "Downloading ${file}"
cd /workspace/ComfyUI/models/loras/

url="https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/${file}?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi
