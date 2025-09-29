#!/usr/bin/env bash

echo "Checking inswapper_128.onnx"
dir="/workspace/ComfyUI/models/insightface"
mkdir -p ${dir}
cd ${dir}
file="inswapper_128.onnx"
url="https://huggingface.co/ezioruan/inswapper_128.onnx/resolve/main/inswapper_128.onnx?download=true"

if [ -f "$file" ]; then
    echo "$file already exists."
else
    echo "Downloading $file"
    wget -O $file $url --progress=bar:force:noscroll
fi
