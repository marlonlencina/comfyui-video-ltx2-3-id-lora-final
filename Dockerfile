# RunPod Serverless ComfyUI base image
FROM runpod/worker-comfyui:5.8.4-base

# Install ComfyUI-KJNodes
RUN git clone --depth 1 \
        https://github.com/kijai/ComfyUI-KJNodes.git \
        /comfyui/custom_nodes/ComfyUI-KJNodes \
    && pip install --no-cache-dir \
        -r /comfyui/custom_nodes/ComfyUI-KJNodes/requirements.txt

# Configure ComfyUI to read models from the attached Network Volume
COPY extra_model_paths.yaml \
     /comfyui/extra_model_paths.yaml

# Placeholder inputs referenced by the API workflow
COPY input/vintage_thinker.png \
     /comfyui/input/vintage_thinker.png

COPY input/ltx23_reference_audio.mp3 \
     /comfyui/input/ltx23_reference_audio.mp3