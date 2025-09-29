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

# Check if there is a venv directory, if so, activate it
if [ -d "/workspace/venv" ]; then
    echo "venv directory found, using existing virtual environment..."
else
    echo "No venv directory found, installing to /workspace/venv..."
    python3 -m venv /workspace/venv
fi
source /workspace/venv/bin/activate

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

# Ensure pip and numpy are up to date
echo "Using python from $(which python)"
echo "Python version: $(python --version)"
echo "Using pip from $(which pip)"
echo "Upgrading pip and numpy..."
pip install --upgrade pip numpy
echo "Pip version: $(pip --version)"
echo "ComfyUI version: $(cd /workspace/ComfyUI && git rev-parse HEAD)"
echo "AI-Toolkit version: $(cd /workspace/ai-toolkit && git rev-parse HEAD)"
echo "Path: $PATH"

# Ensure latest JupyterLab
echo "Installing/Upgrading JupyterLab..."
pip3 install -U jupyterlab
# Start JupyterLab in the background
echo "Starting JupyterLab..."
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.allow_origin='*' &
echo "JupyterLab started"

# Check if user's script exists in /workspace
if [ ! -f /workspace/start_user.sh ]; then
    # If not, copy the original script to /workspace
    echo "No user script found, copying the original script to /workspace/start_user.sh"
    cp /scripts/boot-user.sh /workspace/start_user.sh
else:
    echo "Existing user script found, will not overwrite /workspace/start_user.sh"
fi

# Execute the user's script
bash /workspace/start_user.sh

sleep infinity
