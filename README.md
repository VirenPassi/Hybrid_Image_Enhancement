# Automatic Image Enhancement System

A lightweight trained automatic image enhancement system implemented in MATLAB using classical image processing techniques.

## System Overview

This system automatically enhances images based on learned statistics from a training dataset. It adapts enhancement parameters based on the characteristics of the input image compared to the training data.

## Project Structure

```
project_root/
├── train.m              # Training phase script
├── enhance.m            # Enhancement phase script  
├── compare.m            # Comparison and evaluation script
├── README.md            # This file
├── trained_params.mat   # Saved trained parameters (generated)
├── comparison_results.mat # Comparison results (generated)
├── dataset_extracted/   # Training dataset folder
│   └── archive/
│       └── aerials/
│           └── aerials/ # Place USC-SIPI aerial images here
└── test_images/         # Test images folder
```

## Requirements

- MATLAB R2018a or later
- Image Processing Toolbox

## Usage Instructions

### 1. Training Phase

First, you need to train the system using the USC-SIPI aerial dataset:

1. Download the USC-SIPI aerial images dataset
2. Place the images in: `dataset_extracted/archive/aerials/aerials/`
3. Run the training script:

```matlab
train()
```

This will:
- Process all images in the dataset folder
- Compute average brightness and contrast statistics
- Save trained parameters to `trained_params.mat`

### 2. Enhancement Phase

Enhance a single image using the trained system:

```matlab
% Load your test image
test_img = imread('path/to/your/image.jpg');

% Apply enhancement
enhanced_img = enhance(test_img);

% Display results
figure;
subplot(1,2,1); imshow(test_img); title('Original');
subplot(1,2,2); imshow(enhanced_img); title('Enhanced');
```

### 3. Comparison Phase

Compare the proposed method against baseline methods:

```matlab
% Compare methods on a test image
compare('path/to/test/image.jpg');
```

This will:
- Apply histogram equalization (baseline)
- Apply CLAHE (baseline) 
- Apply proposed adaptive method
- Compute PSNR and MSE metrics
- Display side-by-side visualization
- Save results to `comparison_results.mat`

## System Features

### Adaptive Enhancement Logic

The system makes intelligent decisions based on image statistics:

1. **Brightness Analysis**: 
   - If image brightness < (dataset_avg - 0.5 × dataset_std): Apply brightness enhancement
   - Otherwise: No brightness adjustment

2. **Contrast Analysis**:
   - If image contrast < (dataset_avg - 0.5 × dataset_std): Apply CLAHE
   - Otherwise: No contrast enhancement

3. **Always Applied**:
   - Median filtering for noise reduction
   - Sharpening for improved clarity

### Evaluation Metrics

- **PSNR (Peak Signal-to-Noise Ratio)**: Higher is better
- **MSE (Mean Squared Error)**: Lower is better

## Example Workflow

```matlab
% 1. Training (do this once)
train()

% 2. Enhancement
img = imread('test_images/sample.jpg');
enhanced = enhance(img);
imshow(enhanced);

% 3. Comparison with baselines
compare('test_images/sample.jpg');
```

## Customization

You can modify the enhancement parameters in `enhance.m`:

- Brightness adjustment factor limits
- CLAHE clip limit
- Median filter size
- Sharpening parameters

## Notes

- The system works with both grayscale and RGB images
- All processing is converted to grayscale internally for consistency
- Results are saved as 8-bit unsigned integers (uint8)
- The system is lightweight and doesn't require deep learning frameworks

## Troubleshooting

**Error: "Dataset folder not found"**
- Ensure USC-SIPI images are in the correct folder structure
- Check that `dataset_extracted/archive/aerials/aerials/` exists

**Error: "Trained parameters file not found"**
- Run `train()` first to generate `trained_params.mat`

**Poor enhancement results**
- Try adjusting the threshold parameters in `enhance.m`
- Consider retraining with a different dataset