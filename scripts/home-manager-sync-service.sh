#!/bin/bash

# Navigate to the Logseq directory
cd "$HOME_MANAGER_DIR"
git pull origin main
# Monitor the directory for changes
inotifywait -m -e  modify,create,delete,move -r . --exclude '(\.git)' --format '%w %e'|
while read -r file event; do
    # Print the event details (optional)
    echo "Detected event: $event on $file"
    # Pull any changes from the remote repository
    git pull origin main

    # Add any new or modified files to the staging area
    git add .

    # Check if there are any changes to commit
    if ! git diff --cached --quiet; then
        # Get the latest commit message
        last_commit_message=$(git log -1 --pretty=%B)
        
        # Extract the current version number
        if [[ $last_commit_message =~ Version\ ([0-9]+) ]]; then
            current_version=${BASH_REMATCH[1]}
            new_version=$((current_version + 1))
        else
            # If no version found, start at 1
            new_version=1
        fi

        # Commit the changes with the new version
        git commit -m "Version $new_version"
        # Commit the changes with a message if there are any
        git commit -m "Automated sync"

        # Push the changes to the remote repository
        git push origin main
    fi
    sleep 30
done
