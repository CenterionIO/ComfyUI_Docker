# Base NVIDIA runtime image for 5090+ (CUDA 12.8)
FROM nvcr.io/nvidia/pytorch:25.01-py3

WORKDIR /workspace

# Core OS deps
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    git wget curl ffmpeg libsm6 libxext6 && \
    rm -rf /var/lib/apt/lists/*

# --- Clone ComfyUI directly from source
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git

WORKDIR /workspace/ComfyUI
RUN pip install --no-cache-dir -r requirements.txt

# --- Clone ComfyUI Manager from source
RUN git clone --depth=1 https://github.com/Comfy-Org/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager && \
    if [ -f custom_nodes/ComfyUI-Manager/requirements.txt ]; then \
        pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt; \
    fi

# --- Default port and entrypoint
EXPOSE 8188
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
