function enhanced_img = auto_enhancer_final(image_path)
% AUTO_ENHANCER_FINAL - Adaptive Multi-Defect Correction + Perceptual Enhancement
% Final version of MATLAB auto image enhancer (updated to fix validation issues)
% Author: Final Auto Enhancer System
% Date: February 2026

    % Validate input
    if nargin < 1 || isempty(image_path)
        error('Usage: enhanced_img = auto_enhancer_final(image_path)');
    end
    
    if ~exist(image_path, 'file')
        error('ERROR: Input image file not found: %s', image_path);
    end
    
    fprintf('\n===============================================================\n');
    fprintf('         ADAPTIVE MULTI-DEFECT CORRECTION + PERCEPTUAL ENHANCEMENT\n');
    fprintf('===============================================================\n\n');
    
    % Initialize enhancement report variables
    detected_defects = {};
    applied_operations = {};
    skipped_operations = {};
    
    % STEP 1 — Analyze image
    fprintf('STEP 1: Analyzing image...\n');
    
    original = imread(image_path);
    img = im2double(original);
    
    % Convert to grayscale for analysis
    if size(img, 3) == 3
        gray = im2gray(img);
    else
        gray = img;
    end
    
    % Detect salt & pepper noise (count extreme pixels)
    sp_ratio = sum(gray(:)==0 | gray(:)==1)/numel(gray);
    
    % Detect blur (variance of Laplacian)
    lap = del2(gray);
    blur_metric = var(lap(:));
    
    % Detect gaussian noise (difference from smoothed)
    smoothed_gray = imgaussfilt(gray, 1);
    noise_est = std(double(gray(:)) - double(smoothed_gray(:)));
    
    % Detect low contrast (std intensity)
    contrast_val = std(gray(:));
    
    % Detect low brightness (mean intensity)
    mean_brightness = mean(gray(:));
    
    fprintf('Analysis Results:\n');
    fprintf('  Salt & Pepper Ratio: %.4f\n', sp_ratio);
    fprintf('  Blur Metric: %.6f\n', blur_metric);
    fprintf('  Gaussian Noise: %.4f\n', noise_est);
    fprintf('  Contrast: %.4f\n', contrast_val);
    fprintf('  Brightness: %.4f\n\n', mean_brightness);
    
    % Add detected defects to report
    if sp_ratio > 0.02
        detected_defects{end+1} = 'Salt & Pepper Noise';
    end
    if blur_metric < 0.001
        detected_defects{end+1} = 'Blur';
    end
    if noise_est > 0.05
        detected_defects{end+1} = 'Gaussian Noise';
    end
    if contrast_val < 0.08
        detected_defects{end+1} = 'Low Contrast';
    end
    if mean_brightness < 0.4
        detected_defects{end+1} = 'Low Brightness';
    end
    
    % Initialize noise correction flag
    noise_corrected = false;
    
    % STEP 2 — Targeted correction
    fprintf('STEP 2: Applying targeted corrections...\n');
    
    % IF salt_pepper > 0.02 → Apply 5x5 median filter FIRST
    if sp_ratio > 0.02
        fprintf('  Applying salt & pepper noise correction (5x5 median filter)...\n');
        if size(img, 3) == 3
            img(:,:,1) = medfilt2(img(:,:,1), [5 5]);
            img(:,:,2) = medfilt2(img(:,:,2), [5 5]);
            img(:,:,3) = medfilt2(img(:,:,3), [5 5]);
        else
            img = medfilt2(img, [5 5]);
        end
        noise_corrected = true;
        applied_operations{end+1} = 'Salt & Pepper Correction (5x5 median)';
    else
        skipped_operations{end+1} = 'Salt & Pepper Correction (ratio <= 0.02)';
    end
    
    % IF gaussian_noise → apply imbilatfilt
    if noise_est > 0.05 && ~noise_corrected
        fprintf('  Applying Gaussian noise correction...\n');
        if size(img, 3) == 3
            img(:,:,1) = imbilatfilt(img(:,:,1));
            img(:,:,2) = imbilatfilt(img(:,:,2));
            img(:,:,3) = imbilatfilt(img(:,:,3));
        else
            img = imbilatfilt(img);
        end
        noise_corrected = true;
        applied_operations{end+1} = 'Gaussian Noise Correction (imbilatfilt)';
    else
        if noise_est > 0.05
            skipped_operations{end+1} = 'Gaussian Noise Correction (noise already corrected)';
        else
            skipped_operations{end+1} = 'Gaussian Noise Correction (noise <= 0.05)';
        end
    end
    
    % IF blur → apply mild imsharpen Radius=1.2 Amount=0.8
    if blur_metric < 0.001
        fprintf('  Applying blur correction...\n');
        img = imsharpen(img, 'Radius', 1.2, 'Amount', 0.8);
        applied_operations{end+1} = 'Blur Correction (imsharpen R=1.2, A=0.8)';
    else
        skipped_operations{end+1} = 'Blur Correction (blur metric >= 0.001)';
    end
    
    % IF low_contrast → apply improved contrast correction
    if contrast_val < 0.08
        fprintf('  Applying low contrast correction...\n');
        if contrast_val < 0.06
            % Apply gentle contrast stretch for very low contrast
            if size(img, 3) == 3
                img(:,:,1) = imadjust(img(:,:,1), [0.02 0.98], [0 1]);
                img(:,:,2) = imadjust(img(:,:,2), [0.02 0.98], [0 1]);
                img(:,:,3) = imadjust(img(:,:,3), [0.02 0.98], [0 1]);
            else
                img = imadjust(img, [0.02 0.98], [0 1]);
            end
            applied_operations{end+1} = 'Low Contrast Correction (imadjust [0.02 0.98])';
        else
            % Apply imadjust with stretchlim for moderate low contrast
            if size(img, 3) == 3
                % Apply imadjust with stretchlim to each channel separately
                img(:,:,1) = imadjust(img(:,:,1), stretchlim(img(:,:,1), [0.01 0.99]), []);
                img(:,:,2) = imadjust(img(:,:,2), stretchlim(img(:,:,2), [0.01 0.99]), []);
                img(:,:,3) = imadjust(img(:,:,3), stretchlim(img(:,:,3), [0.01 0.99]), []);
            else
                img = imadjust(img, stretchlim(img, [0.01 0.99]), []);
            end
            applied_operations{end+1} = 'Low Contrast Correction (stretchlim [0.01 0.99])';
        end
    else
        skipped_operations{end+1} = 'Low Contrast Correction (contrast >= 0.08)';
    end
    
    % IF low_brightness → gamma correction 0.9
    if mean_brightness < 0.4
        fprintf('  Applying low brightness correction...\n');
        img = imadjust(img, [], [], 0.9);
        applied_operations{end+1} = 'Low Brightness Correction (gamma 0.9)';
    else
        skipped_operations{end+1} = 'Low Brightness Correction (brightness >= 0.4)';
    end
    
    % STEP 3 — Gentle perceptual polish
    fprintf('STEP 3: Applying gentle perceptual polish...\n');
    
    % Apply sharpening ONLY if no noise was corrected (to avoid amplifying noise)
    if ~noise_corrected
        img = imsharpen(img, 'Radius', 1, 'Amount', 0.5);
        applied_operations{end+1} = 'Perceptual Polish (imsharpen R=1, A=0.5)';
    else
        fprintf('  Skipping sharpening due to noise correction applied.\n');
        skipped_operations{end+1} = 'Perceptual Polish (sharpening skipped due to noise correction)';
    end
    
    % Convert to output format
    enhanced_img = im2uint8(img);
    
    % STEP 4 — Quality safeguard
    fprintf('STEP 4: Performing quality safeguard...\n');
    
    original_double = im2double(original);
    enhanced_double = im2double(enhanced_img);
    
    % Handle different image sizes
    if size(original_double, 1) ~= size(enhanced_double, 1) || ...
       size(original_double, 2) ~= size(enhanced_double, 2)
        original_for_comparison = imresize(original_double, size(enhanced_double, [1,2]));
    else
        original_for_comparison = original_double;
    end
    
    % Compute SSIM(original, enhanced)
    if size(original_for_comparison, 3) == 3 && size(enhanced_double, 3) == 3
        % For color images, compute SSIM on grayscale
        orig_gray = im2gray(original_for_comparison);
        enh_gray = im2gray(enhanced_double);
        ssim_value = ssim(orig_gray, enh_gray);
    else
        % For grayscale images
        ssim_value = ssim(original_for_comparison, enhanced_double);
    end
    
    fprintf('  SSIM between original and enhanced: %.4f\n', ssim_value);
    
    % IF SSIM < 0.45 revert to original
    if ssim_value < 0.45
        fprintf('  SSIM < 0.45 - reverting to original image.\n');
        enhanced_img = original;
        enhancement_decision = 'REVERTED';
    else
        fprintf('  Enhancement accepted.\n');
        enhancement_decision = 'ACCEPTED';
    end
    
    % Print enhancement report
    fprintf('\n-----------------------------------\n');
    fprintf('ENHANCEMENT REPORT\n');
    fprintf('-----------------------------------\n');
    fprintf('Detected Defects:\n');
    if isempty(detected_defects)
        fprintf('  None\n');
    else
        for i = 1:length(detected_defects)
            fprintf('  - %s\n', detected_defects{i});
        end
    end
    fprintf('\nApplied Operations:\n');
    if isempty(applied_operations)
        fprintf('  None\n');
    else
        for i = 1:length(applied_operations)
            fprintf('  - %s\n', applied_operations{i});
        end
    end
    fprintf('\nSkipped Operations:\n');
    if isempty(skipped_operations)
        fprintf('  None\n');
    else
        for i = 1:length(skipped_operations)
            fprintf('  - %s\n', skipped_operations{i});
        end
    end
    fprintf('\nQuality Validation:\n');
    fprintf('SSIM value: %.4f\n', ssim_value);
    fprintf('Decision: %s\n', enhancement_decision);
    fprintf('-----------------------------------\n');
    
    % Display: Original vs Enhanced side-by-side
    figure('Name', 'Final Auto Enhancer Results', 'Position', [100, 100, 1200, 500]);
    
    subplot(1, 2, 1);
    imshow(original);
    title('Original Image', 'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1, 2, 2);
    imshow(enhanced_img);
    title('Enhanced Image', 'FontSize', 14, 'FontWeight', 'bold');
    
    sgtitle('Adaptive Multi-Defect Correction + Perceptual Enhancement', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Save to results directory
    if ~exist('results', 'dir')
        mkdir('results');
        fprintf('\nCreated results directory\n');
    end
    
    [~, name, ext] = fileparts(image_path);
    output_filename = sprintf('enhanced_final_%s.png', name);
    output_path = fullfile('results', output_filename);
    
    imwrite(enhanced_img, output_path);
    fprintf('\nFinal enhanced image saved to: %s\n', output_path);
    fprintf('Adaptive multi-defect correction + perceptual enhancement completed successfully!\n');
    
end