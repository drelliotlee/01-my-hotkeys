#!/bin/bash
# /usr/local/bin/study
# chmod +x /usr/local/bin/study
#
# Usage:
#   study sync   # Commit and push Obsidian STUDY vault

case "$1" in
    "sync")
        target_dir="/home/elliot/Dropbox/Obsidian/STUDY"

        if [[ ! -d "$target_dir" ]]; then
            echo "Error: $target_dir not found."
            exit 1
        fi

        (
            cd "$target_dir" || exit 1

            # Ensure repo exists
            if ! git rev-parse --is-inside-work-tree &>/dev/null; then
                echo "Error: $target_dir is not a Git repository."
                exit 1
            fi

            git add .

            # Commit only if there are changes
            if ! git diff --cached --quiet; then
                msg="$(date +"%Y-%m-%d %H:%M:%S %Z")"
                git commit -m "$msg"
            else
                echo "No staged changes to commit."
            fi

            git push
        )
        ;;

    ""|"help"|"-h"|"--help")
        echo "Usage: study sync"
        ;;

    *)
        echo "Unknown command: $1" >&2
        echo "Usage: study sync" >&2
        exit 1
        ;;
esac
