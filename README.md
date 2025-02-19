# Generative Models: What do they know? Do they know things? Let's find out!

[Xiaodan Du](https://xiaodan.io),
[Nick Kolkin&dagger;](https://home.ttic.edu/~nickkolkin/home.html),
[Greg Shakhnarovich](https://home.ttic.edu/~gregory/),
[Anand Bhattad](https://anandbhattad.github.io/)

Toyota Technological Institute at Chicago, &dagger;Adobe Research

Abstract: *Generative models have been shown to be capable of synthesizing highly detailed and realistic images. It is natural to suspect that they implicitly learn to model some image intrinsics such as surface normals, depth, or shadows. In this paper, we present compelling evidence that generative models indeed internally produce high-quality scene intrinsic maps. We introduce **Intrinsic-LoRA**, a universal, plug-and-play approach that transforms any generative model into a scene intrinsic predictor, capable of extracting intrinsic scene maps directly from the original generator network without needing additional decoders or fully fine-tuning the original network. Our method employs a Low-Rank Adaptation (LoRA) of key feature maps, with newly learned parameters that make up less than 0.6% of the total parameters in the generative model. Optimized with a small set of labeled images, our model-agnostic approach adapts to various generative architectures, including Diffusion models, GANs, and Autoregressive models.  We show that the scene intrinsic maps produced by our method compare well with, and in some cases surpass those generated by leading supervised techniques.*


<a href="https://arxiv.org/abs/2311.17137"><img src="https://img.shields.io/badge/arXiv-2311.17137-b31b1b.svg" height=22.5></a>
<a href="https://intrinsic-lora.github.io/"><img src="https://img.shields.io/website?down_color=lightgrey&down_message=offline&label=Project%20Page&up_color=lightgreen&up_message=online&url=https%3A%2F%2Fintrinsic-lora.github.io" height=22.5></a>


<p align="center">
<img src="assets/I-lora.gif" width=1000/>


## License
Since we use Stable Diffusion, we are releasing under their CreativeML Open RAIL-M license. 

## Updates
2024/2/13: We now provide inference code: `inference_sd_single.py`

2024/1/2: We provide checkpoints for our single step SD model. You can download them at [GDrive](https://drive.google.com/drive/folders/1BV2IQp6itGIi6QQS7Vgug4G7slJ3yDTG?usp=sharing). Load the checkpoint using 

```bash
pipeline.unet.load_attn_procs(torch.load('path/to/ckpt.bin'))
```

## Getting Started

**The main packages are listed below**
```bash
#Conda
pillow=9.2.0
python=3.8.15
pytorch=1.13.0
tokenizers=0.13.0.dev0
torchvision=0.14.0
tqdm=4.64.1
transformers=4.25.1
#pip
accelerate==0.22.0
diffusers==0.20.2
einops==0.6.1
huggingface-hub==0.16.4
numpy==1.22.4
wandb==0.12.21
```
**Get Necessary Stable Diffusion Checkpoints from [HuggingFace🤗](https://huggingface.co/models).**<br> 
We train our single-step UNet model using [SDv1.5](https://huggingface.co/runwayml/stable-diffusion-v1-5) and multi-step AugUNet model using [SDv2.1](https://huggingface.co/stabilityai/stable-diffusion-2-1). We initialize the additional input channels in AugUNet with [IP2P](https://huggingface.co/timbrooks/instruct-pix2pix).


## Usage
We provide code for training the single-step UNet models and the multi-step AugUNet models for surface normal and depth map extraction. Code for albedo and shading should be very similar. Please note that the code is developed for DIODE dataset. To train a model using your own dataset, you need to modify the dataloader. Here we assume that the pseudo labels are stored in the same folder structure as DIODE dataset.  <br><br>
Run the following command to train surface normal single-step UNet model
```bash
export MODEL_NAME="runwayml/stable-diffusion-v1-5"
export DATA_DIR="path/to/DIODE/normals"
export PSEUDO_DIR="path/to/pseudo/labels"
export HF_HOME="path/to/HuggingFace/cache/folder"

accelerate launch sd_single_diode_pseudo_normal.py \
--pretrained_model_name_or_path=$MODEL_NAME  \
--train_data_dir=$DATA_DIR \
--pseudo_root=$PSEUDO_DIR \
--output_dir="path/to/output/dir" \
--train_batch_size=4 \
--dataloader_num_workers=4 \
--learning_rate=1e-4 \
--report_to="wandb" \
--lr_warmup_steps=0 \
--max_train_steps=20000 \
--validation_steps=2500 \
--checkpointing_steps=2500 \
--rank=8 \
--scene_types='outdoor,indoors' \
--num_train_imgs=4000 \
--unified_prompt='surface normal' \
--resume_from_checkpoint='latest' \
--seed=1234
```
Run the following command to train depth single-step UNet model
```bash
export MODEL_NAME="runwayml/stable-diffusion-v1-5"
export DATA_DIR="path/to/DIODE/depths"
export PSEUDO_DIR="path/to/pseudo/labels"
export HF_HOME="path/to/HuggingFace/cache/folder"

accelerate launch sd_single_diode_pseudo_depth.py \
--pretrained_model_name_or_path=$MODEL_NAME  \
--train_data_dir=$DATA_DIR \
--pseudo_root=$PSEUDO_DIR \
--output_dir="path/to/output/dir" \
--train_batch_size=4 \
--dataloader_num_workers=4 \
--learning_rate=1e-4 \
--report_to="wandb" \
--lr_warmup_steps=0 \
--max_train_steps=20000 \
--validation_steps=2500 \
--checkpointing_steps=2500 \
--rank=8 \
--scene_types='outdoor,indoors' \
--num_train_imgs=4000 \
--unified_prompt='depth map' \
--resume_from_checkpoint='latest' \
--seed=1234
```
Run the following code to train surface normal multi-step AugUNet model
```bash
export MODEL_NAME="stabilityai/stable-diffusion-2-1"
export DATA_DIR="path/to/DIODE/normals"
export PSEUDO_DIR="path/to/pseudo/labels"
export HF_HOME="path/to/HuggingFace/cache/folder"

accelerate launch augunet_diode_pseudo_normal.py \
--pretrained_model_name_or_path=$MODEL_NAME  \
--train_data_dir=$DATA_DIR \
--pseudo_root=$PSEUDO_DIR \
--output_dir="path/to/output/dir" \
--train_batch_size=4 \
--dataloader_num_workers=4 \
--learning_rate=1e-4 \
--report_to="wandb" \
--lr_warmup_steps=0 \
--max_train_steps=50000 \
--validation_steps=2500 \
--checkpointing_steps=2500 \
--rank=8 \
--scene_types='outdoor,indoors' \
--unified_prompt='surface normal' \
--resume_from_checkpoint='latest' \
--seed=1234
```
Run the following code to train depth multi-step AugUNet model
```bash
export MODEL_NAME="stabilityai/stable-diffusion-2-1"
export DATA_DIR="path/to/DIODE/depths"
export PSEUDO_DIR="path/to/pseudo/labels"
export HF_HOME="path/to/HuggingFace/cache/folder"

accelerate launch augunet_diode_pseudo_depth.py \
--pretrained_model_name_or_path=$MODEL_NAME  \
--train_data_dir=$DATA_DIR \
--pseudo_root=$PSEUDO_DIR \
--output_dir="path/to/output/dir" \
--train_batch_size=4 \
--dataloader_num_workers=4 \
--learning_rate=1e-4 \
--report_to="wandb" \
--lr_warmup_steps=0 \
--max_train_steps=50000 \
--validation_steps=2500 \
--checkpointing_steps=2500 \
--rank=8 \
--scene_types='outdoor,indoors' \
--unified_prompt='depth map' \
--resume_from_checkpoint='latest' \
--seed=1234
```
Our code should be compatible with "fp16" precision by just appending `--mixed_precision="fp16"` to `accelerate launch`. However we train all of our models using the full precision. Please let us know if you encounter problems using "fp16".<br>



## BibTex
```
@article{du2023generative,
  author    = {Du, Xiaodan and Kolkin, Nicholas and Shakhnarovich, Greg and Bhattad, Anand},
  title     = {Generative Models: What do they know? Do they know things? Let's find out!},
  journal   = {arXiv},
  year      = {2023},
}
```