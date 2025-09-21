#!/bin/bash
# 10activate-venv-env.sh
# This activates the Python virtual environment for the notebook server

# Get the actual user home directory
USER_HOME="${HOME:-/home/${NB_USER:-jovyan}}"
VENV_PATH="${USER_HOME}/.venv"

if [ -f "${VENV_PATH}/bin/activate" ]; then
    source "${VENV_PATH}/bin/activate"
    echo "✓ Activated virtual environment: ${VENV_PATH}"
    echo "Python: $(python --version) at $(which python)"
else
    echo "⚠ Virtual environment not found at ${VENV_PATH}"
    echo "Using system Python: $(python3 --version) at $(which python3)"
fi

