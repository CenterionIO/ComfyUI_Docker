#!/bin/bash
set -e

# Check if ComfyUI exists, if not clone it
if [ ! -d "/workspace/ComfyUI" ]; then
    echo "ComfyUI not found, cloning..."
    cd /workspace
    git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git
    cd ComfyUI
    pip install --no-cache-dir -r requirements.txt

    # Install ComfyUI Manager if not present
    if [ ! -d "custom_nodes/ComfyUI-Manager" ]; then
        git clone --depth=1 https://github.com/Comfy-Org/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
        if [ -f custom_nodes/ComfyUI-Manager/requirements.txt ]; then
            pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt
        fi
    fi

    # Create model folders
    mkdir -p models/{checkpoints,clip_vision,text_encoders,loras,vae}
fi

# Start code-server in background (disable with ENABLE_CODESERVER=false)
if [ "$ENABLE_CODESERVER" != "false" ]; then
    echo "Starting code-server on port 8080..."
    code-server --bind-addr 0.0.0.0:8080 --auth none /workspace &
fi

# Give services a moment to start
sleep 2

# Navigate to ComfyUI and run
cd /workspace/ComfyUI
exec python main.py --listen 0.0.0.0 --port 8188 "$@"
