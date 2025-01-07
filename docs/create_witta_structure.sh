#!/bin/bash

# Base directory name
BASE_DIR="witta-core"

# Create the base directory
mkdir -p $BASE_DIR

# Create subdirectories
mkdir -p $BASE_DIR/app
mkdir -p $BASE_DIR/app/api
mkdir -p $BASE_DIR/app/core
mkdir -p $BASE_DIR/app/utils
mkdir -p $BASE_DIR/tests

# Create placeholder files
touch $BASE_DIR/app/__init__.py
touch $BASE_DIR/app/api/__init__.py
touch $BASE_DIR/app/api/endpoints.py
touch $BASE_DIR/app/core/__init__.py
touch $BASE_DIR/app/core/orchestrator.py
touch $BASE_DIR/app/core/api_manager.py
touch $BASE_DIR/app/core/data_manager.py
touch $BASE_DIR/app/utils/logger.py
touch $BASE_DIR/app/utils/config.py
touch $BASE_DIR/tests/test_api.py
touch $BASE_DIR/tests/test_core.py

# Create other necessary files
touch $BASE_DIR/Dockerfile
touch $BASE_DIR/requirements.txt
touch $BASE_DIR/README.md

# Confirmation message
echo "WITTA Core directory structure created successfully!"
