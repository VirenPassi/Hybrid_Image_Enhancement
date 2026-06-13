# Intelligent Hybrid Image Enhancement for Smart Consumer Devices

![MATLAB](https://img.shields.io/badge/MATLAB-R2021a+-blue?logo=mathworks)
![Python](https://img.shields.io/badge/Python-3.8+-yellow?logo=python)
![AI Engine](https://img.shields.io/badge/AI_Engine-RealESRGAN_v0.3.0-orange)
![Publication](https://img.shields.io/badge/Accepted-ICCE--Taiwan_(IEEE)-success)

> **Official codebase for the research paper:** *Intelligent Hybrid Image Enhancement for Smart Consumer Devices Using Classical and AI-Based Super-Resolution.*

## 📖 Overview

Conventional image enhancement methods often fail on severely degraded images, while state-of-the-art AI super-resolution models introduce artifacts and require high computational resources. 

This repository presents a novel **Adaptive Hybrid Enhancement Framework** that intelligently bridges this gap. By utilizing resolution and variance metrics, the system automatically routes images between a lightweight classical processing pipeline (**Safe Mode**) and a heavy AI super-resolution engine (**Boost Mode**). Furthermore, the framework incorporates an explainable AI layer, generating attention difference heatmaps and zoomed ROI comparisons to validate structural stability.

---

## ✨ Key System Features

1. **Adaptive Trigger Mechanism:** Analyzes input resolution and blur (via Laplacian variance). 
   * *Logic:* `If (resolution < 400px AND variance >= 0.001) -> Safe Mode`, `Else -> Boost Mode`.
2. **Safe Mode (Classical):** Applies histogram equalization, contrast stretching, and sharpening for mildly degraded images, ensuring zero artificial hallucination.
3. **Boost Mode (AI Super-Resolution):** Seamlessly invokes the included `realesrgan-ncnn-vulkan` engine via a Python bridge for severe degradation, recovering high-frequency details.
4. **Explainable Validation:** Automatically generates SSIM structural similarity scores and visual heatmaps to compare the original and enhanced outputs.

---

## 📊 Quantitative Performance

The proposed framework was evaluated across 200 challenging images (DIV2K downscaled, Gaussian blur, and AWGN). The hybrid approach significantly outperformed classical-only baseline methods in maintaining structural fidelity.

| Image Degradation | Original SSIM | Safe Mode SSIM | Boost Mode SSIM |
| :--- | :---: | :---: | :---: |
| **Low Resolution** | 0.62 | 0.71 | **0.84** |
| **Blurred Image** | 0.58 | 0.68 | **0.82** |
| **Noisy Image** | 0.54 | **0.73** | 0.79 |

---

## 📂 Project Structure

```text
DIG PROJECT (QODER)/
│
├── enhancement_pipeline.m          # Main entry point for the hybrid framework
├── auto_enhancer_multi_defect.m    # Core logic for handling various degradations
├── evaluate_multi_defect_system.m  # Batch validation and SSIM metric generation
├── compare_enhancers.m             # Script to generate visual heatmaps and ROI comparisons
│
├── realesrgan_enhance.py           # Python bridge communicating with the AI engine
├── realesrgan-ncnn-vulkan.exe      # Compiled AI super-resolution executable
│
└── trained_params.mat              # Saved threshold parameters for the adaptive trigger
```
## 🚀 Quick Start Guide 

1. Prerequisites
- MATLAB (R2018a or newer with Image Processing Toolbox)

- Python 3.8+ (Must be added to system PATH for MATLAB to execute it)

2. Running a Single Image Enhancement
- To process a single image and see the adaptive trigger in action, load your image into MATLAB and run the main pipeline:

Matlab
```text
% Load your test image
input_img = imread('path/to/degraded_image.jpg');

% Run the hybrid enhancement pipeline
[enhanced_img, active_mode, ssim_score] = enhancement_pipeline(input_img);

% Display the results
disp(['System selected: ', active_mode]);
disp(['Structural Similarity (SSIM): ', num2str(ssim_score)]);
3. Running the Validation Suite
To reproduce the quantitative results from the paper, use the built-in evaluation script:


% Run full comparison against standard baselines
evaluate_multi_defect_system();

% Generate visual heatmaps for explainability
compare_enhancers('path/to/test_image.jpg');
```

## 🎓 Citation
If you use this framework or find our research helpful, please cite our IEEE publication:

Code snippet
@inproceedings{passi2026hybridimage,
  title={Intelligent Hybrid Image Enhancement for Smart Consumer Devices Using Classical and AI-Based Super-Resolution},
  author={Passi, Viren and others},
  booktitle={2026 IEEE International Conference on Consumer Electronics-Taiwan (ICCE-Taiwan)},
  year={2026},
  organization={IEEE}
}
