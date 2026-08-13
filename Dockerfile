# RunPod Serverless ComfyUI base image
FROM runpod/worker-comfyui:5.8.4-base

# Optional token for Hugging Face downloads
ARG HF_TOKEN=""

# Install ComfyUI-KJNodes at the revision tested in the Pod
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git \
        /comfyui/custom_nodes/ComfyUI-KJNodes \
    && git -C /comfyui/custom_nodes/ComfyUI-KJNodes \
        checkout d19ce9078f03cc66a462efc082defd30aef16d02 \
    && if [ -f /comfyui/custom_nodes/ComfyUI-KJNodes/requirements.txt ]; then \
        pip install --no-cache-dir \
            -r /comfyui/custom_nodes/ComfyUI-KJNodes/requirements.txt; \
       fi

# LTX 2.3 FP8 checkpoint
RUN BACKOFFS="10 20 30 60 90" \
    && for i in 1 2 3 4 5; do \
        HF_TOKEN="$HF_TOKEN" comfy model download \
            --url "https://huggingface.co/Lightricks/LTX-2.3-fp8/resolve/main/ltx-2.3-22b-dev-fp8.safetensors" \
            --relative-path "models/checkpoints" \
            --filename "ltx-2.3-22b-dev-fp8.safetensors" \
        && break; \
        if [ "$i" -eq 5 ]; then \
            echo "LTX 2.3 checkpoint download failed" >&2; \
            exit 1; \
        fi; \
        SLEEP=$(echo "$BACKOFFS" | cut -d " " -f "$i"); \
        echo "Retrying in ${SLEEP}s" >&2; \
        sleep "$SLEEP"; \
    done

# LTX 2.3 distilled LoRA
RUN BACKOFFS="10 20 30 60 90" \
    && for i in 1 2 3 4 5; do \
        HF_TOKEN="$HF_TOKEN" comfy model download \
            --url "https://huggingface.co/Comfy-Org/ltx-2.3/resolve/main/split_files/loras/ltx_2.3_22b_distilled_1.1_lora_dynamic_fro09_avg_rank_111_bf16.safetensors" \
            --relative-path "models/loras" \
            --filename "ltx_2.3_22b_distilled_1.1_lora_dynamic_fro09_avg_rank_111_bf16.safetensors" \
        && break; \
        if [ "$i" -eq 5 ]; then \
            echo "Distilled LoRA download failed" >&2; \
            exit 1; \
        fi; \
        SLEEP=$(echo "$BACKOFFS" | cut -d " " -f "$i"); \
        echo "Retrying in ${SLEEP}s" >&2; \
        sleep "$SLEEP"; \
    done

# Gemma 3 text encoder
RUN BACKOFFS="10 20 30 60 90" \
    && for i in 1 2 3 4 5; do \
        HF_TOKEN="$HF_TOKEN" comfy model download \
            --url "https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors" \
            --relative-path "models/text_encoders" \
            --filename "gemma_3_12B_it_fp4_mixed.safetensors" \
        && break; \
        if [ "$i" -eq 5 ]; then \
            echo "Gemma text encoder download failed" >&2; \
            exit 1; \
        fi; \
        SLEEP=$(echo "$BACKOFFS" | cut -d " " -f "$i"); \
        echo "Retrying in ${SLEEP}s" >&2; \
        sleep "$SLEEP"; \
    done

# LTX 2.3 spatial upscaler
RUN BACKOFFS="10 20 30 60 90" \
    && for i in 1 2 3 4 5; do \
        HF_TOKEN="$HF_TOKEN" comfy model download \
            --url "https://huggingface.co/Lightricks/LTX-2.3/resolve/main/ltx-2.3-spatial-upscaler-x2-1.1.safetensors" \
            --relative-path "models/latent_upscale_models" \
            --filename "ltx-2.3-spatial-upscaler-x2-1.1.safetensors" \
        && break; \
        if [ "$i" -eq 5 ]; then \
            echo "Spatial upscaler download failed" >&2; \
            exit 1; \
        fi; \
        SLEEP=$(echo "$BACKOFFS" | cut -d " " -f "$i"); \
        echo "Retrying in ${SLEEP}s" >&2; \
        sleep "$SLEEP"; \
    done

# LTX 2.3 ID-LoRA TalkVid
RUN BACKOFFS="10 20 30 60 90" \
    && for i in 1 2 3 4 5; do \
        HF_TOKEN="$HF_TOKEN" comfy model download \
            --url "https://huggingface.co/AviadDahan/LTX-2.3-ID-LoRA-TalkVid-3K/resolve/main/lora_weights.safetensors" \
            --relative-path "models/loras" \
            --filename "ltx-2.3-id-lora-talkvid-3k.safetensors" \
        && break; \
        if [ "$i" -eq 5 ]; then \
            echo "ID-LoRA download failed" >&2; \
            exit 1; \
        fi; \
        SLEEP=$(echo "$BACKOFFS" | cut -d " " -f "$i"); \
        echo "Retrying in ${SLEEP}s" >&2; \
        sleep "$SLEEP"; \
    done

# Placeholder inputs referenced by api-workflow.json
COPY input/vintage_thinker.png \
     /comfyui/input/vintage_thinker.png

COPY input/ltx23_reference_audio.mp3 \
     /comfyui/input/ltx23_reference_audio.mp3