#!/bin/bash

echo "Disabling Mixlab nodes..."
dir="/workspace/ComfyUI/custom_nodes/comfyui-mixlab-nodes"

if [ -d "$dir" ]
then
    mv "$dir" "$dir.disabled"
    echo "Mixlab nodes has been disabled successfully."
fi
echo "Mixlab nodes are disabled. To enable them again, rename the directory back to 'comfyui-mixlab-nodes'."