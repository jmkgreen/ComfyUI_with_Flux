#!/usr/bin/env bash

echo "Donwloading Upscale models"

echo "Downloading 4x-UltraSharp.pth"
cd /workspace/ComfyUI/models/upscale_models
file="4x-UltraSharp.pth"
url="https://huggingface.co/lokCX/4x-Ultrasharp/resolve/main/4x-UltraSharp.pth?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi