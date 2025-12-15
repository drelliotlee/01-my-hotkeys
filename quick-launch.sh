#!/bin/bash

# A script to quickly launch different applications based on a command-line flag.

# Check the first command-line argument ($1).
case "$1" in
    # If the argument is "-e", run the 'nemo' file manager.
    -e)
        echo "Launching Nemo..."
        nemo /home/elliot/Documents &
        ;;
    # If the argument is "-t", run the 'gnome-terminal'.
    -t)
        echo "Launching Gnome Terminal..."
        gnome-terminal &
        ;;
    # If the argument is "-c", run the 'speedcrunch' calculator.
    -c)
        echo "Launching Speedcrunch..."
        speedcrunch &
        ;;
    # Handle any other arguments or no arguments.
    *)
        echo "Invalid or no option provided."
        echo "Usage: $0 [option]"
        echo "Options:"
        echo "  -e  Launches Nemo"
        echo "  -t  Launches Gnome Terminal"
        echo "  -c  Launches Speedcrunch"
        exit 1
        ;;
esac

# The '&' at the end of each command runs the application in the background,
# which allows the script to complete and return to the prompt immediately.
