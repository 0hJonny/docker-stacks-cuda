#!/bin/bash
# Universal jupyter wrapper for venv

# Определить модуль по имени команды
CMD_NAME=$(basename "$0")
case "$CMD_NAME" in
    "jupyter-lab") MODULE="jupyterlab" ;;
    "jupyter-labhub") MODULE="jupyterlab.labhubapp" ;;
    "jupyter-notebook") MODULE="notebook" ;;
    "jupyter-server") MODULE="jupyter_server" ;;
    "jupyter") MODULE="jupyter" ;;
    *) MODULE="jupyter" ;;
esac

# Активировать venv и запустить
source "/home/jovyan/.venv/bin/activate"
exec python -m "$MODULE" "$@"
