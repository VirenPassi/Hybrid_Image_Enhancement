function enhanced_img = auto_enhancer_multi_defect(image_path)
% AUTO_ENHANCER_MULTI_DEFECT - Adaptive Multi-Defect Enhancement System
% Preserves perceptual visual boost while correcting multiple image defects
% Corrects: blur, salt & pepper noise, Gaussian noise, low contrast, low brightness
% Author: Multi-Defect Enhancement System
% Date: February 2026

    % Validate input
    if nargin < 1 || isempty(image_path)
        error('Usage: enhanced_img = auto_enhancer_multi_defect(image_path)');
    end
    
    if ~exist(image_path, 'file')
        error('ERROR: Input image file not found: %s', image_path);
    end
    
    fprintf('\n===============================================================\n');
    fprintf('         ADAPTIVE MULTI-DEFECT ENHANCEMENT SYSTEM\n');
    fprintf('===============================================================\n\n');
    
    % 1) Load image using recommended method
    fprintf('Loading input image: %s\n', image_path);
    original = imread(image_path);
    img = im2double(original);
    
    % Preserve original for display
    original_display = original;
    
    % 2) Compute analysis metrics
    if size(img, 3) == 3
        gray = im2gray(img);
    else
        gray = img;
    end
    
    mean_brightness = mean(gray(:));
    contrast_val = std(gray(:));
    
    % Blur detection (Variance of Laplacian)
    lap = del2(gray);
    blur_metric = var(lap(:));
    
    % Salt & pepper detection
    sp_ratio = sum(gray(:)==0 | gray(:)==1)/numel(gray);
    
    % Gaussian noise estimation
    smoothed_gray = imgaussfilt(gray, 1);
    noise_est = std(double(gray(:)) - double(smoothed_gray(:)));
    
    fprintf('Image Analysis Results:\n');
    fprintf('  Mean Brightness: %.3f\n', mean_brightness);
    fprintf('  Contrast: %.3f\n', contrast_val);
    fprintf('  Blur Metric: %.6f\n', blur_metric);
    fprintf('  Salt & Pepper Ratio: %.4f\n', sp_ratio);
    fprintf('  Noise Estimate: %.4f\n\n', noise_est);
    
    % Track which corrections are applied
    applied_corrections = {};
    
    % 3) Defect-Specific Corrections
    
    % A) Salt & pepper noise correction
    if sp_ratio > 0.02
        fprintf('Correcting salt & pepper noise (>0.02 threshold)...\n');
        if size(img, 3) == 3
            % Apply median filtering (3x3) per channel
            img(:,:,1) = medfilt2(img(:,:,1), [3 3]);
            img(:,:,2) = medfilt2(img(:,:,2), [3 3]);
            img(:,:,3) = medfilt2(img(:,:,3), [3 3]);
        else
            img = medfilt2(img, [3 3]);
        end
        applied_corrections{end+1} = 'Salt & Pepper Noise Correction';
    end
    
    % B) Gaussian noise correction
    if sp_ratio <= 0.02 && noise_est > 0.05  % Only if no salt & pepper noise
        fprintf('Correcting Gaussian noise (>0.05 threshold)...\n');
        if size(img, 3) == 3
            % Apply bilateral filter per channel
            img(:,:,1) = imbilatfilt(img(:,:,1));
            img(:,:,2) = imbilatfilt(img(:,:,2));
            img(:,:,3) = imbilatfilt(img(:,:,3));
        else
            img = imbilatfilt(img);
        end
        applied_corrections{end+1} = 'Gaussian Noise Correction';
    end
    
    % C) Blur correction
    blur_threshold = 0.001;  % Adjusted threshold for blur detection
    if blur_metric < blur_threshold
        fprintf('Correcting blur (blur_metric < %.5f threshold)...\n', blur_threshold);
        img = imsharpen(img, 'Radius', 2.5, 'Amount', 1.5);
        applied_corrections{end+1} = 'Blur Correction';
    end
    
    % D) Low contrast correction
    if contrast_val < 0.08
        fprintf('Correcting low contrast (contrast < 0.08 threshold)...\n');
        if size(img, 3) == 3
            % Apply CLAHE to luminance channel only to preserve color
            lab_img = rgb2lab(img);
            lab_img(:,:,1) = adapthisteq(lab_img(:,:,1), 'ClipLimit', 0.01);
            img = lab2rgb(lab_img);
        else
            img = adapthisteq(img, 'ClipLimit', 0.01);
        end
        applied_corrections{end+1} = 'Low Contrast Correction';
    end
    
    % E) Low brightness correction
    if mean_brightness < 0.4
        fprintf('Correcting low brightness (brightness < 0.4 threshold)...\n');
        img = imadjust(img, [], [], 0.8);  % Apply gamma 0.8
        applied_corrections{end+1} = 'Low Brightness Correction';
    end
    
    % 4) Final perceptual polish
    fprintf('\nApplying final perceptual polish...\n');
    if size(img, 3) == 3
        % Process each channel separately for RGB images
        img(:,:,1) = imadjust(img(:,:,1));
        img(:,:,2) = imadjust(img(:,:,2));
        img(:,:,3) = imadjust(img(:,:,3));
    else
        img = imadjust(img);
    end
    img = imsharpen(img, 'Radius', 1.5, 'Amount', 1.0);
    applied_corrections{end+1} = 'Final Perceptual Polish';
    
    % 5) Convert to output format
    enhanced_img = im2uint8(img);
    
    % Safeguard mechanism: Compare original and enhanced image quality
    original_double = im2double(original_display);
    enhanced_double = im2double(enhanced_img);
    
    % Handle different image sizes
    if size(original_double, 1) ~= size(enhanced_double, 1) || ...
       size(original_double, 2) ~= size(enhanced_double, 2)
        original_for_comparison = imresize(original_double, size(enhanced_double, [1,2]));
    else
        original_for_comparison = original_double;
    end
    
    % Compute SSIM between original and enhanced
    if size(original_for_comparison, 3) == 3 && size(enhanced_double, 3) == 3
        % For color images, compute SSIM on grayscale
        orig_gray = im2gray(original_for_comparison);
        enh_gray = im2gray(enhanced_double);
        ssim_value = ssim(orig_gray, enh_gray);
    else
        % For grayscale images
        ssim_value = ssim(original_for_comparison, enhanced_double);
    end
    
    % Determine if any significant defect was detected
    defects_applied_count = length(applied_corrections) - 1; % Exclude final perceptual polish
    any_defect_detected = defects_applied_count > 0;
    
    % Apply safeguard logic
    if ~any_defect_detected && ssim_value < 0.95
        fprintf('No significant defect detected — returning original image.\n');
        enhanced_img = original_display;
    elseif ssim_value < 0.3  % Only revert if there's a severe quality drop
        fprintf('Severe quality drop detected — reverting to original image.\n');
        enhanced_img = original_display;
    else
        fprintf('Enhancement accepted - SSIM: %.4f\n', ssim_value);
    end
    
    % Display applied corrections
    fprintf('\nApplied Corrections (%d total):\n', length(applied_corrections));
    if isempty(applied_corrections)
        fprintf('  No significant defects detected - minimal processing applied\n');
    else
        for i = 1:length(applied_corrections)
            fprintf('  %d. %s\n', i, applied_corrections{i});
        end
    end
    
    % Display results
    figure('Name', 'Multi-Defect Enhancement Results', 'Position', [100, 100, 1200, 500]);
    
    subplot(1, 2, 1);
    imshow(original_display);
    title('Original Image', 'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1, 2, 2);
    imshow(enhanced_img);
    title('Multi-Defect Enhanced', 'FontSize', 14, 'FontWeight', 'bold');
    
    sgtitle('Adaptive Multi-Defect Enhancement System', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Save to results directory
    if ~exist('results', 'dir')
        mkdir('results');
        fprintf('\nCreated results directory\n');
    end
    
    [~, name, ext] = fileparts(image_path);
    output_filename = sprintf('enhanced_multidefect_%s.png', name);
    output_path = fullfile('results', output_filename);
    
    imwrite(enhanced_img, output_path);
    fprintf('\nMulti-defect enhanced image saved to: %s\n', output_path);
    fprintf('Adaptive multi-defect enhancement completed successfully!\n');
    
end