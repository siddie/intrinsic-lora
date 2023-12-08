export MODEL_NAME="runwayml/stable-diffusion-v1-5"
export DATA_DIR="/share/data/2pals/xdu/diffusers_examples/datasets/DIODE/depths"
export HF_HOME="/share/data/pals/xdu/cache"

accelerate launch --mixed_precision="fp16" sd_single_diode_pseudo_depth.py \
--pretrained_model_name_or_path=$MODEL_NAME  \
--train_data_dir=$DATA_DIR \
--pseudo_root='/share/data/2pals/xdu/diffusers_examples/metrics_output/DIODE/depths/omnidatav2' \
--output_dir="exps/debug_sdsingledepth" \
--train_batch_size=4 \
--dataloader_num_workers=4 \
--learning_rate=1e-4 \
--report_to="wandb" \
--lr_warmup_steps=0 \
--max_train_steps=10 \
--validation_steps=5 \
--checkpointing_steps=5 \
--rank=8 \
--scene_types='outdoor,indoors' \
--num_train_imgs=4000 \
--unified_prompt='depth map' \
--resume_from_checkpoint='latest' \
--seed=42