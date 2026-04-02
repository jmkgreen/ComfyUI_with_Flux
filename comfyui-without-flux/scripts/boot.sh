#!/usr/bin/env bash

echo "pod started"

GPU_FINGERPRINT_FILE="/workspace/venv/.gpu-fingerprint"
CURRENT_GPU_FINGERPRINT="unknown"
FORCE_PACKAGE_UPDATE="${FORCE_PACKAGE_UPDATE:-0}"
TORCH_INDEX_URL="${TORCH_INDEX_URL:-https://download.pytorch.org/whl/cu129}"

if command -v nvidia-smi >/dev/null 2>&1; then
    CURRENT_GPU_FINGERPRINT="$(nvidia-smi --query-gpu=name,compute_cap,driver_version --format=csv,noheader | head -n 1)"
fi

echo "Detected GPU fingerprint: ${CURRENT_GPU_FINGERPRINT}"

install_base_packages() {
    pip install --upgrade pip setuptools wheel gguf segment-anything onnx onnxruntime
    pip install numpy==1.26.4
    pip install piexif==1.1.3
    pip3 install --upgrade torch torchvision torchaudio --index-url "${TORCH_INDEX_URL}"
    pip3 install jupyterlab
}

reinstall_torch_stack() {
    echo "Reinstalling torch stack from ${TORCH_INDEX_URL}..."
    pip3 install --upgrade --force-reinstall --no-cache-dir torch torchvision torchaudio --index-url "${TORCH_INDEX_URL}"
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
        pip uninstall -y sageattention >/dev/null 2>&1 || true
    fi

    if [ "${ENABLE_XFORMERS:-0}" = "1" ]; then
        echo "ENABLE_XFORMERS=1, attempting to install xformers..."
        if ! pip install xformers; then
            echo "WARNING: xformers installation failed."
            if [ "${STRICT_CUDA_EXTENSION_INSTALL:-0}" = "1" ]; then
                echo "STRICT_CUDA_EXTENSION_INSTALL=1, stopping startup."
                exit 1
            fi
            echo "Continuing without xformers."
            pip uninstall -y xformers >/dev/null 2>&1 || true
        fi
    else
        echo "Skipping xformers install (set ENABLE_XFORMERS=1 to enable)."
        pip uninstall -y xformers >/dev/null 2>&1 || true
    fi
}

run_cuda_self_test() {
    python3 - <<'PY'
import sys
import torch

try:
    if not torch.cuda.is_available():
        print("CUDA self-test: torch.cuda.is_available() is false")
        raise RuntimeError("cuda_not_available")

    device_name = torch.cuda.get_device_name(0)
    x = torch.randn((512, 512), device="cuda")
    y = torch.mm(x, x)
    torch.cuda.synchronize()
    print(f"CUDA self-test passed on: {device_name}; mean={y.mean().item():.6f}")
except Exception as exc:
    message = str(exc).lower()
    print(f"CUDA self-test failed: {exc}")
    if "no kernel image is available" in message or "cudaerrornokernelimagefordevice" in message:
        sys.exit(86)
    sys.exit(1)
PY
}

run_cuda_self_test_with_recovery() {
    if [ "${RUN_CUDA_SELF_TEST:-1}" != "1" ]; then
        echo "Skipping CUDA self-test (set RUN_CUDA_SELF_TEST=1 to enable)."
        return 0
    fi

    run_cuda_self_test
    CUDA_TEST_RC=$?

    if [ "${CUDA_TEST_RC}" = "86" ] && [ "${AUTO_RECOVER_CUDA_KERNEL_IMAGE_ERROR:-1}" = "1" ]; then
        echo "Detected 'no kernel image' CUDA failure. Running automatic recovery..."
        pip uninstall -y xformers sageattention >/dev/null 2>&1 || true
        reinstall_torch_stack
        install_optional_cuda_extensions
        run_cuda_self_test
        CUDA_TEST_RC=$?
    fi

    if [ "${CUDA_TEST_RC}" != "0" ]; then
        echo "CUDA self-test did not pass (exit code: ${CUDA_TEST_RC})."
        if [ "${STRICT_CUDA_SELF_TEST:-1}" = "1" ]; then
            echo "STRICT_CUDA_SELF_TEST=1, stopping startup to avoid runtime generation failures."
            exit 1
        fi
        echo "Continuing startup despite CUDA self-test failure."
    fi
}

install_torchvision_nms_fallback_patch() {
    if [ "${ENABLE_TORCHVISION_NMS_CPU_FALLBACK:-1}" != "1" ]; then
        echo "Skipping torchvision NMS CPU fallback patch (set ENABLE_TORCHVISION_NMS_CPU_FALLBACK=1 to enable)."
        return 0
    fi

    python3 - <<'PY'
import pathlib
import site

PATCH_CONTENT = """\
\"\"\"Runtime compatibility patch for GPUs where torchvision CUDA NMS kernels are unavailable.\"\"\"

from __future__ import annotations


def _install_torchvision_nms_cpu_fallback() -> None:
    try:
        import torch
        import torchvision.ops as tv_ops
    except Exception:
        return

    original_nms = getattr(tv_ops, "nms", None)
    if original_nms is None:
        return

    if getattr(original_nms, "_kernel_image_fallback_wrapped", False):
        return

    def _nms_with_fallback(boxes, scores, iou_threshold):
        try:
            return original_nms(boxes, scores, iou_threshold)
        except Exception as exc:
            message = str(exc).lower()
            if "no kernel image is available" not in message and "cudaerrornokernelimagefordevice" not in message:
                raise

            if hasattr(boxes, "is_cuda") and boxes.is_cuda:
                cpu_idx = original_nms(boxes.detach().cpu(), scores.detach().cpu(), iou_threshold)
                return cpu_idx.to(boxes.device)
            raise

    _nms_with_fallback._kernel_image_fallback_wrapped = True
    tv_ops.nms = _nms_with_fallback


_install_torchvision_nms_cpu_fallback()
"""

site_packages = []
for getter in (site.getsitepackages,):
    try:
        site_packages.extend(getter())
    except Exception:
        pass

try:
    user_site = site.getusersitepackages()
    if user_site:
        site_packages.append(user_site)
except Exception:
    pass

for sp in site_packages:
    path = pathlib.Path(sp)
    if path.exists() and "site-packages" in str(path):
        target = path / "sitecustomize.py"
        target.write_text(PATCH_CONTENT, encoding="utf-8")
        print(f"Installed torchvision NMS fallback patch at {target}")
        break
else:
    print("WARNING: could not locate site-packages to install torchvision NMS fallback patch")
PY
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

install_torchvision_nms_fallback_patch

if [ "${CURRENT_GPU_FINGERPRINT}" != "unknown" ]; then
    echo "${CURRENT_GPU_FINGERPRINT}" > "${GPU_FINGERPRINT_FILE}"
fi

echo "Using python from $(which python)"
echo "Python version: $(python --version)"
echo "Pip version: $(pip --version)"

# Move ComfyUI's folder to $VOLUME so models and all config will persist
/scripts/comfyui-on-workspace.sh

# ComfyUI requirements may reintroduce xformers; keep it opt-in to avoid
# architecture-specific kernel image issues on mixed GPU fleets.
if [ "${ENABLE_XFORMERS:-0}" != "1" ]; then
    pip uninstall -y xformers >/dev/null 2>&1 || true
fi

# Move ai-toolkit's folder to $VOLUME so models and all config will persist
/scripts/ai-toolkit-on-workspace.sh

run_cuda_self_test_with_recovery

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
