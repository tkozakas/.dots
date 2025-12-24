#!/bin/bash
set -e
curl https://mise.run | sh
eval "$(~/.local/bin/mise activate bash)"
mise trust && task
