# ====================================================================
# ComfyUI + Manager Runtime (CUDA 12.8 / cuDNN 9 / PyTorch 2.7)
# Compatible with RTX 5090 and newer
# ====================================================================

FROM pytorch/pytorch:2.7.0-cuda12.8-cudnn9-devel

# --- System setup
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    git wget curl ffmpeg libsm6 libxext6 \
 && rm -rf /var/lib/apt/lists/*

# --- Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# --- Clone and install ComfyUI
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /workspace/ComfyUI

# Install base requirements
RUN pip install --no-cache-dir -r requirements.txt

# --- Install SageAttention (requires CUDA toolkit from devel image)
RUN pip install --no-cache-dir triton && \
    pip install --no-cache-dir sageattention==2.2.0 --no-build-isolation

# --- Install ComfyUI Manager (official)
RUN git clone --depth=1 https://github.com/Comfy-Org/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager \
 && if [ -f custom_nodes/ComfyUI-Manager/requirements.txt ]; then \
        pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt; \
    fi

# --- Create default model folders
RUN mkdir -p /workspace/ComfyUI/models/{checkpoints,clip_vision,text_encoders,loras,vae}

# --- Copy and setup entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# --- Expose ports
EXPOSE 8188
EXPOSE 8080

# --- Set working directory and entrypoint
WORKDIR /workspace
ENTRYPOINT ["/entrypoint.sh"]
