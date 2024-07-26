#!/bin/bash

# Directory containing the .jsonl files
RESULTS_DIR="../results"

# Loop over each .jsonl file in the results directory
for FILE in "$RESULTS_DIR"/*.jsonl
do
  # Check if the file exists (in case no .jsonl files are found)
  if [ -e "$FILE" ]; then
    echo "Processing $FILE..."
    bigcodebench.evaluate --subset instruct --samples "$FILE" --no-gt --decision n
    echo "Clean up"
    for pid in $(ps aux | grep bigcodebench.evaluate | grep -v grep | awk '{print $2}'); do kill $pid; done
  else
    echo "No .jsonl files found in $RESULTS_DIR."
    exit 1
  fi
done
