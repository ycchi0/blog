#!/bin/bash

# quick.sh - A script to quickly run deploy.sh or new.sh

# Check if the user has provided an argument
if [ $# -eq 0 ]; then
  echo "Usage: quick.sh {d|n}"
  echo "  d: Run deploy.sh script"
  echo "  n: Run new.sh script"
  exit 1
fi

# Define the directory where scripts are located
SCRIPT_DIR="scripts"

# Check the first argument and run the corresponding script
case $1 in
  d)
    # Run deploy.sh
    if [ -f "$SCRIPT_DIR/deploy.sh" ]; then
      echo "Running deploy.sh..."
      "$SCRIPT_DIR/deploy.sh"
    else
      echo "Error: deploy.sh does not exist in $SCRIPT_DIR"
      exit 2
    fi
    ;;
  n)
    # Run new.sh
    if [ -f "$SCRIPT_DIR/new.sh" ]; then
      echo "Running new.sh..."
      "$SCRIPT_DIR/new.sh"
    else
      echo "Error: new.sh does not exist in $SCRIPT_DIR"
      exit 3
    fi
    ;;
  *)
    # Handle invalid arguments
    echo "Invalid argument: $1"
    echo "Valid arguments are 'd' for deploy and 'n' for new."
    exit 4
    ;;
esac

exit 0