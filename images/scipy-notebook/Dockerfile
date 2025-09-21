# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_IMAGE=$REGISTRY/$OWNER/minimal-notebook
FROM $BASE_IMAGE

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # for cython: https://cython.readthedocs.io/en/latest/src/quickstart/install.html
    build-essential \
    # for latex labels
    cm-super \
    dvipng \
    # for matplotlib anim
    ffmpeg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# macOS Rosetta virtualization creates junk directory which gets owned by root further up.
# It'll get re-created, but as USER runner after the next directive so hopefully should not cause permission issues.
#
# More info: https://github.com/jupyter/docker-stacks/issues/2296
RUN rm -rf "/home/${NB_USER}/.cache/"

# Build arguments
ARG CUDA_BUILD=0
ARG CMAKE_ARGS=""

USER ${NB_UID}

# Install Python 3 packages
RUN "${HOME}/.venv/bin/pip" install --no-cache-dir \
    'altair' \
    'catboost' 'lightgbm'\
    'bokeh' \
    'bottleneck' \
    'h5py' \
    'ipympl' \
    'ipywidgets' \
    'jupyterlab-git' \
    'numexpr' \
    'openpyxl' \
    'seaborn[stats]' \
    'protobuf' \
    'scikit-image' \
    'statsmodels' \
    'widgetsnbextension' \
    'xlrd' && \
    "${HOME}/.venv/bin/pip" cache purge && \
    fix-permissions "/home/${NB_USER}"

# Install facets package which does not have a `pip` or `conda-forge` package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets && \
    jupyter nbclassic-extension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "/home/${NB_USER}"

# Import matplotlib the first time to build the font cache
RUN MPLBACKEND=Agg "${HOME}/.venv/bin/python" -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

# macOS Rosetta virtualization creates junk directory which gets owned by root further up.
# It'll get re-created, but as USER runner after the next directive so hopefully should not cause permission issues.
#
# More info: https://github.com/jupyter/docker-stacks/issues/2296
RUN rm -rf "/home/${NB_USER}/.cache/pip"

USER ${NB_UID}

WORKDIR "${HOME}"
