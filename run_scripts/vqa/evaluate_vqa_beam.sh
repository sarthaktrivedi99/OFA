#!/usr/bin/env bash

# The port for communication. Note that if you want to run multiple tasks on the same machine,
# you need to specify different port numbers.
export MASTER_PORT=8082

user_dir=../../ofa_module
bpe_dir=../../utils/BPE

# val or test
split=test

data=../../dataset/vizwiz_data/vizwiz_${split}.tsv
ans2label_file=../../dataset/vizwiz_data/trainval_ans2label.pkl
path=../../checkpoints/checkpoint_best.pt
result_path=../../results/vizwiz_${split}_beam
selected_cols=0,5,2,3,4

CUDA_VISIBLE_DEVICES=0 python3 -m torch.distributed.launch --nproc_per_node=1 --master_port=${MASTER_PORT} ../../evaluate.py \
    "${data}" \
    --path=${path} \
    --user-dir=${user_dir} \
    --task=vqa_gen \
    --batch-size=8 \
    --log-format=simple --log-interval=10 \
    --seed=7 \
    --gen-subset="${split}" \
    --results-path="${result_path}" \
    --fp16 \
    --ema-eval \
    --beam-search-vqa-eval \
    --beam=5 \
    --unnormalized \
    --temperature=1.0 \
    --num-workers=0 \
    --model-overrides="{\"data\":\"${data}\",\"bpe_dir\":\"${bpe_dir}\",\"selected_cols\":\"${selected_cols}\",\"ans2label_file\":\"${ans2label_file}\"}"
