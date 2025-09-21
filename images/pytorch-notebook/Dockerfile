# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_IMAGE=$REGISTRY/$OWNER/scipy-notebook
FROM $BASE_IMAGE

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build arguments
ARG CUDA_BUILD=0
ARG CMAKE_ARGS=""

USER ${NB_UID}

# Install PyTorch with pip (https://pytorch.org/get-started/locally/)
# hadolint ignore=DL3013
RUN set -ex && \
    CMAKE_ARGS="-DGGML_CUDA=on -DGGML_CUDA_FORCE_CUBLAS=on -DCMAKE_CUDA_ARCHITECTURES=native" FORCE_CMAKE=1 "${HOME}/.venv/bin/pip" install 'llama-cpp-python' && \
    "${HOME}/.venv/bin/pip" cache purge && \
    \
    # LangChain Core
    "${HOME}/.venv/bin/pip" install --no-cache-dir 'langchain-core==0.3.76' 'uvicorn' && \
    "${HOME}/.venv/bin/pip" cache purge && \
    \
    # LangChain основные пакеты
    "${HOME}/.venv/bin/pip" install --no-cache-dir \
    'langchain==0.3.27' \
    'langchain-text-splitters==0.3.11' \
    'langchain-community==0.3.27' \
    'langchain-ollama==0.3.8' && \
    "${HOME}/.venv/bin/pip" cache purge && \
    \
    # JAX с CUDA
    "${HOME}/.venv/bin/pip" install --no-cache-dir \
    'jax[cuda12]==0.7.1' \
    'jaxlib==0.7.1' && \
    "${HOME}/.venv/bin/pip" cache purge && \
    \
    # Transformers и токенизаторы
    "${HOME}/.venv/bin/pip" install --no-cache-dir \
    'transformers' 'tokenizers' && \
    "${HOME}/.venv/bin/pip" cache purge && \
    \
    # ML утилиты
    "${HOME}/.venv/bin/pip" install --no-cache-dir \
    'sentence-transformers' 'nltk' && \
    "${HOME}/.venv/bin/pip" cache purge && \
    \
    # Глубокая очистка временных файлов
    rm -rf ~/.cache/pip/* /tmp/pip-* /tmp/tmp* && \
    fix-permissions "/home/${NB_USER}"

# Скачивание и сборка llama.cpp source
RUN set -ex && \
    cd "${HOME}" && \
    wget -O llama.cpp-b6173.tar.gz "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b6173.tar.gz" && \
    tar -xzf llama.cpp-b6173.tar.gz && \
    cd llama.cpp-b6173 && \
    cmake -B build -DGGML_CUDA=ON -DGGML_CUDA_FORCE_CUBLAS=ON && \
    cmake --build build --config Release -j $(nproc) && \
    ls -la "${HOME}/llama.cpp-b6173/build/bin/" || echo "Build directory not found"