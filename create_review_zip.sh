#!/bin/bash

# Script to create a zipped archive of project files for code review

# Define the archive name with a timestamp
ARCHIVE_NAME="code_review_$(date +%Y%m%d_%H%M%S).zip"

# Check if we are in the correct directory
if [[ ! -d .git ]]; then
    echo "Error: This script must be run from the root of a git repository."
    exit 1
fi

# Create the archive, excluding files and directories in .gitignore
git archive --format=zip --output="$ARCHIVE_NAME" HEAD

# Verify if the archive was created successfully
if [[ $? -eq 0 ]]; then
    echo "Code review archive created: $ARCHIVE_NAME"
    echo "You can upload this archive for review."
else
    echo "Error: Failed to create the archive."
    exit 1
fi
