#!/bin/bash


# Check that the logseq directory exists
if [ ! -d "$LOGSEQ_DIR" ]; then
	echo "Logseq directory not found, creating it..."
	mkdir -p "$LOGSEQ_DIR"

	cd "$LOGSEQ_DIR"
	git clone "$LOGSEQ_SYNC_ADDR" .
fi
# Navigate to the Logseq directory
cd "$LOGSEQ_DIR"
git --git-dir=".git-private" config pull.rebase false
git --git-dir=".git-private" pull origin main
git --git-dir=".git-sintef" config pull.rebase false
git --git-dir=".git-sintef" pull origin main
while true; do
	# Monitor the directory for changes
	inotifywait -m -e  modify,create,delete,move -r . --exclude '(\.git)' --format '%w %e' --timeout 10 |
	while read -r file event; do
	    # Print the event details (optional)
	    echo "Detected event: $event on $file"
	    # Pull any changes from the remote repositories
	    git --git-dir=".git-private" pull origin main
	    git --git-dir=".git-sintef" pull origin main

	    # Add any new or modified files to the staging area
        # Sintef repo gets all files
	    git --git-dir=".git-sintef" add -A
	    git --git-dir=".git-private" add -A
        # Private repo ignores "sintef__*" files
	    git --git-dir=".git-private" restore --staged pages/sintef__* 2>/dev/null || true

        ## Sintef Repo ##
        
	    # Check if there are any changes to commit
	    if ! git --git-dir=".git-sintef" diff --cached --quiet; then
		# Commit the changes with a message if there are any
		git --git-dir=".git-sintef" commit -m "Automated sync"
		# Push the changes to the remote repository
		git --git-dir=".git-sintef" push origin main
        fi

        ## Private repo ##

	    # Check if there are any changes to commit
	    if ! git --git-dir=".git-private" diff --cached --quiet; then
		# Commit the changes with a message if there are any
		git --git-dir=".git-private" commit -m "Automated sync"
		# Push the changes to the remote repository
		git --git-dir=".git-private" push origin main
	    fi
	    sleep 120
	done

git --git-dir=".git-sintef" pull origin main
git --git-dir=".git-private" pull origin main
done
