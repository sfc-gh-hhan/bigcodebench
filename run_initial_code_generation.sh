#!/bin/bash
eval "$(conda shell.bash hook)"
conda activate bigcodebenchgen

BS=1
DATASET=bigcodebench
MODEL=$1
BACKEND=$2
MAX_MODEL_LEN=$3 # "" | 8000
QUANTIZATION=$4 # "" | "fp8"
TEMP=0
N_SAMPLES=1
NUM_GPU=1
SUBSET=instruct
if [[ $MODEL == *"/"* ]]; then
  ORG=$(echo $MODEL | cut -d'/' -f1)--
  BASE_MODEL=$(echo $MODEL | cut -d'/' -f2)
else
  ORG=""
  BASE_MODEL=$MODEL
fi

if [ -z "${MAX_MODEL_LEN}" ]; then
  MAX_MODEL_LEN="none"
fi
if [ -z "${QUANTIZATION}" ]; then
  QUANTIZATION="none"
fi

FILE_HEADER=$ORG$BASE_MODEL--$DATASET-$SUBSET--$BACKEND-$TEMP-$N_SAMPLES

echo $FILE_HEADER
bigcodebench.generate \
  --tp $NUM_GPU \
  --model $MODEL \
  --bs $BS \
  --temperature $TEMP \
  --n_samples $N_SAMPLES \
  --resume \
  --subset $SUBSET \
  --backend $BACKEND \
  --trust_remote_code \
  --max_model_len $MAX_MODEL_LEN \
  --quantization $QUANTIZATION

bigcodebench.sanitize --samples $FILE_HEADER.jsonl --calibrate

./eval_single_dspy_result.sh $FILE_HEADER-sanitized-calibrated.jsonl
cp $FILE_HEADER-sanitized-calibrated.jsonl sanitized_calibrated_samples/instruct/ 
cp $FILE_HEADER-sanitized-calibrated_eval_results.json sanitized_calibrated_samples/instruct/
