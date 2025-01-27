#!/bin/bash

# Navigate to the Witta directory (if run from a different location)
cd "$(dirname "$0")" || exit

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    echo "Activating virtual environment..."
    source venv/bin/activate
else
    echo "Virtual environment not found. Ensure dependencies are installed."
fi

# Run the main.py script
echo "Starting the server..."
python3 main.py
