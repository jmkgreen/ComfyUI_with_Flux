#!/usr/bin/env bash

echo "pod started"

if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
fi

# Activate existing venv, or create one and install all packages on first run.
# Packages are NOT upgraded on warm restarts (existing venv) to avoid the
# ~5 min torch download on every pod start. Set FORCE_PACKAGE_UPDATE=1 to
# re-run upgrades without recreating the venv.
if [ -d "/workspace/venv" ]; then
    echo "venv found, activating existing virtual environment..."
    source /workspace/venv/bin/activate
else
    echo "No venv found, creating /workspace/venv and installing packages..."
    python3 -m venv /workspace/venv
    source /workspace/venv/bin/activate
    pip install --upgrade pip setuptools wheel gguf segment-anything sageattention onnx onnxruntime
    pip install numpy==1.26.4
    pip install piexif==1.1.3
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu129
    pip3 install jupyterlab
fi

if [ "${FORCE_PACKAGE_UPDATE}" = "1" ]; then
    echo "FORCE_PACKAGE_UPDATE=1, upgrading packages..."
    pip install --upgrade pip setuptools wheel gguf segment-anything sageattention onnx onnxruntime
    pip install numpy==1.26.4
    pip install piexif==1.1.3
    pip3 install -U torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu129
    pip3 install -U jupyterlab
fi

echo "Using python from $(which python)"
echo "Python version: $(python --version)"
echo "Pip version: $(pip --version)"

# Move ComfyUI's folder to $VOLUME so models and all config will persist
/scripts/comfyui-on-workspace.sh

# Move ai-toolkit's folder to $VOLUME so models and all config will persist
/scripts/ai-toolkit-on-workspace.sh

#!/bin/bash
if [[ -z "${HF_TOKEN}" ]] || [[ "${HF_TOKEN}" == "enter_your_huggingface_token_here" ]]
then
    echo "HF_TOKEN is not set"
else
    echo "HF_TOKEN is set, logging in..."
    huggingface-cli login --token ${HF_TOKEN}
fi

# Start nginx as reverse proxy to enable api access
service nginx start

echo "ComfyUI version: $(cd /workspace/ComfyUI && git rev-parse HEAD)"
echo "AI-Toolkit version: $(cd /workspace/ai-toolkit && git rev-parse HEAD)"
echo "Path: $PATH"

# Start JupyterLab in the background
echo "Starting JupyterLab..."
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.allow_origin='*' &
echo "JupyterLab started"

# Check if user's script exists in /workspace
if [ ! -f /workspace/start_user.sh ]; then
    # If not, copy the original script to /workspace
    echo "No user script found, copying the original script to /workspace/start_user.sh"
    cp /scripts/boot-user.sh /workspace/start_user.sh
else
    echo "Existing user script found, will not overwrite /workspace/start_user.sh"
fi

# Execute the user's script
bash /workspace/start_user.sh

sleep infinity
