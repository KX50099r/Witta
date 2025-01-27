#!/bin/bash

# Navigate to the Witta directory (if needed)
cd "$(dirname "$0")" || exit

# Check if virtual environment is active
if [ -z "$VIRTUAL_ENV" ]; then
    if [ -d "venv" ]; then
        echo "Activating virtual environment..."
        source venv/bin/activate
    else
        echo "Virtual environment not found. Please set it up first."
        exit 1
    fi
else
    echo "Virtual environment already active."
fi

# Start AIDER in architect mode with the correct settings
aider \
    --model gpt-4o \
    --architect \
    --editor-model gpt-4o-mini \
    --yes-always \
    --load .aider
