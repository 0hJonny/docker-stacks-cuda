# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG REGISTRY=hub.docker.com
ARG OWNER=0hjohnny
ARG BASE_IMAGE=$REGISTRY/$OWNER/docker-stacks-foundation
FROM $BASE_IMAGE

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install all OS dependencies for the Server that starts
# but lacks all features (e.g., download as all possible file formats)
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # - Add necessary fonts for matplotlib/seaborn
    #   See https://github.com/jupyter/docker-stacks/pull/380 for details
    fonts-liberation \
    # - `pandoc` is used to convert notebooks to html files
    #   it's not present in the aarch64 Ubuntu image, so we install it here
    pandoc \
    # - `run-one` - a wrapper script that runs no more
    #   than one unique instance of some command with a unique set of arguments,
    #   we use `run-one-constantly` to support the `RESTARTABLE` option
    run-one && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# macOS Rosetta virtualization creates junk directory which gets owned by root further up.
# It'll get re-created, but as USER runner after the next directive so hopefully should not cause permission issues.
#
# More info: https://github.com/jupyter/docker-stacks/issues/2296
RUN rm -rf "/home/${NB_USER}/.cache/"

# 1. Обновить PATH глобально
ENV PATH="/home/jovyan/.venv/bin:${PATH}"
RUN echo 'PATH="/home/jovyan/.venv/bin:$PATH"' >> /etc/environment

# 2. Скопировать wrapper скрипт
COPY venv-jupyter-wrapper.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/venv-jupyter-wrapper.sh

# 3. Заменить команды на wrapper
RUN for cmd in jupyter jupyter-lab jupyter-labhub jupyter-notebook jupyter-server; do \
        if [ -f "/usr/local/bin/$cmd" ]; then \
            mv "/usr/local/bin/$cmd" "/usr/local/bin/$cmd.orig" || true; \
        fi; \
        ln -sf /usr/local/bin/venv-jupyter-wrapper.sh "/usr/local/bin/$cmd"; \
    done

USER ${NB_UID}
ENV PATH="/home/jovyan/.venv/bin:${PATH}"
# Install JupyterHub, JupyterLab, NBClassic and Jupyter Notebook
# Generate a Jupyter Server config
# Cleanup temporary files
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
# WORKDIR /tmp
# RUN mamba install --yes \
#     'jupyterhub-singleuser' \
#     'jupyterlab' \
#     'nbclassic' \
#     # Sometimes, when the new version of `jupyterlab` is released, latest `notebook` might not support it for some time
#     # Old versions of `notebook` (<v7) didn't have a restriction on the `jupyterlab` version, and old `notebook` is getting installed
#     # That's why we have to pin the minimum notebook version
#     # More info: https://github.com/jupyter/docker-stacks/pull/2167
#     'notebook>=7.2.2' && \
#     jupyter server --generate-config && \
#     mamba clean --all -f -y && \
#     jupyter lab clean && \
#     rm -rf "/home/${NB_USER}/.cache/yarn" && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}"
WORKDIR /tmp
RUN set -x && \
    # Устанавливаем пакеты в существующий venv
    "${HOME}/.venv/bin/pip" install --no-cache-dir \
        'jupyterhub' \
        'jupyterlab' \
        'nbclassic' \
        'notebook>=7.2.2' && \
    # Генерируем конфиг jupyter через python модуль
    "${HOME}/.venv/bin/python" -m jupyter server --generate-config && \
    # Очищаем кэш jupyter lab через python модуль
    "${HOME}/.venv/bin/python" -m jupyter lab clean && \
    # Удаляем кэш yarn если есть
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    # Очищаем pip cache
    "${HOME}/.venv/bin/pip" cache purge && \
    # Исправляем права доступа
    fix-permissions "/home/${NB_USER}"

USER root

RUN cp -r /usr/local/share/jupyter /home/${NB_USER}/.venv/share &&\
    chown -R ${NB_UID}:${NB_GID} /home/${NB_USER}/.venv

USER ${NB_UID}

# Исправить права
RUN fix-permissions "/home/${NB_USER}/.venv"

ENV JUPYTER_PORT=8888
EXPOSE $JUPYTER_PORT

# Configure container startup
CMD ["start-notebook.py"]

# Copy local files as late as possible to avoid cache busting
COPY start-notebook.py start-notebook.sh start-singleuser.py start-singleuser.sh /usr/local/bin/
COPY jupyter_server_config.py docker_healthcheck.py /etc/jupyter/

# Fix permissions on /etc/jupyter as root
USER root
RUN fix-permissions /etc/jupyter/

# HEALTHCHECK documentation: https://docs.docker.com/engine/reference/builder/#healthcheck
# This healtcheck works well for `lab`, `notebook`, `nbclassic`, `server`, and `retro` jupyter commands
# https://github.com/jupyter/docker-stacks/issues/915#issuecomment-1068528799
HEALTHCHECK --interval=3s --timeout=1s --start-period=3s --retries=3 \
    CMD /etc/jupyter/docker_healthcheck.py || exit 1

# macOS Rosetta virtualization creates junk directory which gets owned by root further up.
# It'll get re-created, but as USER runner after the next directive so hopefully should not cause permission issues.
#
# More info: https://github.com/jupyter/docker-stacks/issues/2296
RUN rm -rf "/home/${NB_USER}/.cache/"

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}

WORKDIR "${HOME}"
