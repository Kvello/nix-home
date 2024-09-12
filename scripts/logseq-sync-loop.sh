#!/bin/bash


# Check that the logseq directory exists
if [ ! -d "$LOGSEQ_DIR" ]; then
	echo "Logseq directory not found, creating it..."
	mkdir -p "$LOGSEQ_DIR"

	cd "$LOGSEQ_DIR"
	git clone "$LOGSEQ_SYNC_ADDR"
fi
# Navigate to the Logseq directory
cd "$LOGSEQ_DIR"

# Monitor the directory for changes
inotifywait -m -e  modify,create,delete,move -r . >/dev/null |
while read -r; do
    # Pull any changes from the remote repository
    git pull origin master

    # Add any new or modified files to the staging area
    git add .

    # Check if there are any changes to commit
    if ! git diff --cached --quiet; then
        # Commit the changes with a message if there are any
        git commit -m "Automated sync"

        # Push the changes to the remote repository
        git push origin main
    fi
done
