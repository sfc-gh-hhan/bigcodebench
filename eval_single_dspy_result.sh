#!/bin/bash
eval "$(conda shell.bash hook)"
conda activate bigcodebench

path=$1

bigcodebench.evaluate --subset instruct --samples $path --no-gt --decision n
for pid in $(ps aux | grep bigcodebench.evaluate | grep -v grep | awk '{print $2}'); do kill $pid; done
