#!/bin/bash

# Change to the Witta project directory
cd ~/Witta || { echo "Witta directory not found"; exit 1; }

# Add all changes
git add .

# Prompt for commit message
echo "Enter your commit message:"
read -r commit_message

# Commit changes
git commit -m "$commit_message"

# Push to remote repository
git push

echo "End-of-day commit complete!"
