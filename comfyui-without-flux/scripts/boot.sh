#!/usr/bin/env bash

echo "pod started"

GPU_FINGERPRINT_FILE="/workspace/venv/.gpu-fingerprint"
CURRENT_GPU_FINGERPRINT="unknown"
FORCE_PACKAGE_UPDATE="${FORCE_PACKAGE_UPDATE:-0}"

if command -v nvidia-smi >/dev/null 2>&1; then
    CURRENT_GPU_FINGERPRINT="$(nvidia-smi --query-gpu=name,compute_cap,driver_version --format=csv,noheader | head -n 1)"
fi

echo "Detected GPU fingerprint: ${CURRENT_GPU_FINGERPRINT}"

install_base_packages() {
    pip install --upgrade pip setuptools wheel gguf segment-anything onnx onnxruntime
    pip install numpy==1.26.4
    pip install piexif==1.1.3
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu129
    pip3 install jupyterlab
}

install_optional_cuda_extensions() {
    if [ "${ENABLE_SAGEATTENTION:-0}" = "1" ]; then
        echo "ENABLE_SAGEATTENTION=1, attempting to install sageattention..."
        if ! pip install sageattention; then
            echo "WARNING: sageattention installation failed."
            if [ "${STRICT_CUDA_EXTENSION_INSTALL:-0}" = "1" ]; then
                echo "STRICT_CUDA_EXTENSION_INSTALL=1, stopping startup."
                exit 1
            fi
            echo "Continuing without sageattention."
        fi
    else
        echo "Skipping sageattention install (set ENABLE_SAGEATTENTION=1 to enable)."
    fi
}

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

    PREVIOUS_GPU_FINGERPRINT="unknown"
    if [ -f "${GPU_FINGERPRINT_FILE}" ]; then
        PREVIOUS_GPU_FINGERPRINT="$(cat "${GPU_FINGERPRINT_FILE}")"
    elif [ "${AUTO_REFRESH_WHEN_NO_GPU_FINGERPRINT:-1}" = "1" ] && [ "${CURRENT_GPU_FINGERPRINT}" != "unknown" ] && [ "${FORCE_PACKAGE_UPDATE}" != "1" ]; then
        echo "No saved GPU fingerprint found, forcing one-time package refresh."
        FORCE_PACKAGE_UPDATE=1
        if [ "${UNINSTALL_SAGEATTENTION_ON_GPU_CHANGE:-1}" = "1" ]; then
            echo "Removing sageattention before refresh to avoid stale kernels."
            pip uninstall -y sageattention >/dev/null 2>&1 || true
        fi
    fi

    if [ "${CURRENT_GPU_FINGERPRINT}" != "unknown" ] && [ "${PREVIOUS_GPU_FINGERPRINT}" != "unknown" ] && [ "${CURRENT_GPU_FINGERPRINT}" != "${PREVIOUS_GPU_FINGERPRINT}" ]; then
        echo "GPU changed from '${PREVIOUS_GPU_FINGERPRINT}' to '${CURRENT_GPU_FINGERPRINT}'."
        if [ "${AUTO_REFRESH_ON_GPU_CHANGE:-1}" = "1" ] && [ "${FORCE_PACKAGE_UPDATE}" != "1" ]; then
            echo "AUTO_REFRESH_ON_GPU_CHANGE=1, forcing package refresh."
            FORCE_PACKAGE_UPDATE=1
        fi

        if [ "${UNINSTALL_SAGEATTENTION_ON_GPU_CHANGE:-1}" = "1" ]; then
            echo "Removing sageattention to avoid stale GPU-specific kernels."
            pip uninstall -y sageattention >/dev/null 2>&1 || true
        fi
    fi
else
    echo "No venv found, creating /workspace/venv and installing packages..."
    python3 -m venv /workspace/venv
    source /workspace/venv/bin/activate
    install_base_packages
    install_optional_cuda_extensions
fi

if [ "${FORCE_PACKAGE_UPDATE}" = "1" ]; then
    echo "FORCE_PACKAGE_UPDATE=1, upgrading packages..."
    install_base_packages
    install_optional_cuda_extensions
fi

if [ "${CURRENT_GPU_FINGERPRINT}" != "unknown" ]; then
    echo "${CURRENT_GPU_FINGERPRINT}" > "${GPU_FINGERPRINT_FILE}"
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
