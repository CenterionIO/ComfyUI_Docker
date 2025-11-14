# ====================================================================
# ComfyUI + Manager Runtime (CUDA 12.8 / cuDNN 9 / PyTorch 2.9)
# Compatible with RTX 5090 and newer
# ====================================================================

FROM pytorch/pytorch:2.9.0-cuda12.8-cudnn9-runtime

# --- System setup
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    git wget curl ffmpeg libsm6 libxext6 \
 && rm -rf /var/lib/apt/lists/*

# --- Clone and install ComfyUI
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /workspace/ComfyUI

# Install base requirements
RUN pip install --no-cache-dir -r requirements.txt

# --- Install ComfyUI Manager (official)
RUN git clone --depth=1 https://github.com/Comfy-Org/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager \
 && if [ -f custom_nodes/ComfyUI-Manager/requirements.txt ]; then \
        pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt; \
    fi

# --- Create default model folders
RUN mkdir -p /workspace/ComfyUI/models/{checkpoints,clip_vision,text_encoders,loras,vae}

# --- Expose ComfyUI default port
EXPOSE 8188

# --- Launch
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
