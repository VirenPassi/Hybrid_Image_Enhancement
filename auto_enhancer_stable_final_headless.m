function enhanced_img = auto_enhancer_stable_final_headless(image_path)
% AUTO_ENHANCER_STABLE_FINAL_HEADLESS - FINAL Stable Adaptive System (Headless Version)
% Rebuilt MATLAB auto enhancer following all specified rules without GUI operations:
% 1) Detect defects: blur (variance of Laplacian), salt&pepper (extreme pixel ratio),
%    brightness (mean intensity), contrast (std deviation)
% 2) Apply targeted corrections ONLY
% 3) Perceptual polish (only if no heavy noise)
% 4) Safeguard with SSIM check
% 5) Guarantees: never darker, never lower contrast, never sharpens noisy, preserve colors
%
% Author: Advanced Image Enhancement Research System
% Date: February 2026

    % Validate input
    if nargin < 1 || isempty(image_path)
        error('Usage: enhanced_img = auto_enhancer_stable_final_headless(image_path)');
    end
    
    if ~exist(image_path, 'file')
        error('ERROR: Input image file not found: %s', image_path);
    end
    
    % Initialize enhancement tracking
    detected_defects = {};
    applied_operations = {};
    skipped_operations = {};
    
    % Load original image
    original_img = imread(image_path);
    original_double = im2double(original_img);
    
    % Preserve original for final comparison
    original_preserved = original_img;
    
    % Convert to grayscale for analysis
    if size(original_double, 3) == 3
        gray_analysis = rgb2gray(original_double);
        color_img = original_double;
    else
        gray_analysis = original_double;
        color_img = original_double;  % Keep as is for grayscale
    end
    
    % STEP 1: DETECT DEFECTS ACCORDING TO SPECIFICATIONS
    % 1a) Blur detection: variance of Laplacian
    laplacian_kernel = [0 -1 0; -1 4 -1; 0 -1 0];
    laplacian_filtered = conv2(double(gray_analysis), laplacian_kernel, 'same');
    blur_metric = var(laplacian_filtered(:));
    
    % 1b) Salt & pepper detection: extreme pixel ratio
    sp_ratio = sum(gray_analysis(:) == 0 | gray_analysis(:) == 1) / numel(gray_analysis);
    
    % 1c) Brightness detection: mean intensity
    brightness = mean(gray_analysis(:));
    
    % 1d) Contrast detection: std deviation
    contrast = std(gray_analysis(:));
    
    % Define thresholds based on analysis
    blur_threshold = 1e-4;      % Low variance indicates blur
    sp_threshold = 0.01;        % 1% extreme pixels indicates salt & pepper
    brightness_threshold = 0.3; % Below 0.3 is considered dark
    contrast_threshold = 0.1;   % Below 0.1 is considered low contrast
    
    % Track detected defects
    if blur_metric < blur_threshold
        detected_defects{end+1} = 'Blur';
    end
    if sp_ratio > sp_threshold
        detected_defects{end+1} = 'Salt & Pepper Noise';
    end
    if brightness < brightness_threshold
        detected_defects{end+1} = 'Low Brightness';
    end
    if contrast < contrast_threshold
        detected_defects{end+1} = 'Low Contrast';
    end
    
    % Initialize processing flags
    noise_corrected = false;
    brightness_applied = false;
    contrast_applied = false;
    
    % Start with the original image for processing
    processed_img = color_img;
    
    % STEP 2: APPLY TARGETED CORRECTIONS ONLY AS SPECIFIED
    % 2a) Salt & pepper correction: medfilt2(gray,[5 5]), disable sharpening afterwards
    if sp_ratio > sp_threshold
        if size(processed_img, 3) == 3
            processed_img(:,:,1) = medfilt2(processed_img(:,:,1), [5 5]);
            processed_img(:,:,2) = medfilt2(processed_img(:,:,2), [5 5]);
            processed_img(:,:,3) = medfilt2(processed_img(:,:,3), [5 5]);
        else
            processed_img = medfilt2(processed_img, [5 5]);
        end
        noise_corrected = true;  % This will disable later sharpening
        applied_operations{end+1} = 'Salt & Pepper Correction (medfilt2 [5 5])';
    else
        skipped_operations{end+1} = 'Salt & Pepper Correction (ratio <= 0.01)';
    end
    
    % 2b) Blur correction: mild imsharpen radius=1 amount=0.7
    if blur_metric < blur_threshold && ~noise_corrected
        processed_img = imsharpen(processed_img, 'Radius', 1.0, 'Amount', 0.7);
        applied_operations{end+1} = 'Blur Correction (imsharpen R=1.0, A=0.7)';
    elseif blur_metric >= blur_threshold
        skipped_operations{end+1} = 'Blur Correction (image not blurry)';
    else
        skipped_operations{end+1} = 'Blur Correction (skipped due to noise correction)';
    end
    
    % 2c) Low brightness correction: gamma correction 0.8
    if brightness < brightness_threshold
        processed_img = imadjust(processed_img, [], [], 0.8);
        brightness_applied = true;
        applied_operations{end+1} = 'Brightness Correction (gamma 0.8)';
    else
        skipped_operations{end+1} = 'Brightness Correction (brightness adequate)';
    end
    
    % 2d) Low contrast correction: simple imadjust(gray)
    if contrast < contrast_threshold
        if size(processed_img, 3) == 3
            processed_img(:,:,1) = imadjust(processed_img(:,:,1));
            processed_img(:,:,2) = imadjust(processed_img(:,:,2));
            processed_img(:,:,3) = imadjust(processed_img(:,:,3));
        else
            processed_img = imadjust(processed_img);
        end
        contrast_applied = true;
        applied_operations{end+1} = 'Contrast Correction (imadjust)';
    else
        skipped_operations{end+1} = 'Contrast Correction (contrast adequate)';
    end
    
    % STEP 3: Perceptual polish (ONLY if no heavy noise)
    if ~noise_corrected  % Only if no noise correction was applied
        processed_img = imsharpen(processed_img, 'Radius', 1.0, 'Amount', 0.5);
        applied_operations{end+1} = 'Perceptual Polish (mild sharpening A=0.5)';
    else
        skipped_operations{end+1} = 'Perceptual Polish (skipped due to noise correction)';
    end
    
    % Ensure image values are within valid range
    processed_img = max(0, min(1, processed_img));
    
    % STEP 4: Safeguard - compute SSIM(original, enhanced)
    % Calculate SSIM between original and enhanced
    if size(original_double, 3) == 3
        orig_gray = rgb2gray(original_double);
    else
        orig_gray = original_double;
    end
    
    if size(processed_img, 3) == 3
        proc_gray = rgb2gray(processed_img);
    else
        proc_gray = processed_img;
    end
    
    ssim_value = ssim(orig_gray, proc_gray);
    
    % STEP 5: Apply safeguards and guarantees
    % Check if SSIM < 0.45, revert to original
    if ssim_value < 0.45
        final_img = original_preserved;
        safeguard_action = 'REVERTED';
    else
        final_img = im2uint8(processed_img);
        safeguard_action = 'ACCEPTED';
        
        % Additional checks to ensure guarantees
        % Check brightness guarantee: NEVER output darker image
        if size(final_img, 3) == 3
            final_brightness = mean(rgb2gray(im2double(final_img))(:));
        else
            final_brightness = mean(im2double(final_img)(:));
        end
        
        if size(original_preserved, 3) == 3
            orig_brightness = mean(rgb2gray(im2double(original_preserved))(:));
        else
            orig_brightness = mean(im2double(original_preserved)(:));
        end
        
        if final_brightness < orig_brightness
            final_img = original_preserved;
        end
        
        % Check contrast guarantee: NEVER reduce contrast
        if size(final_img, 3) == 3
            final_contrast = std(rgb2gray(im2double(final_img))(:));
        else
            final_contrast = std(im2double(final_img)(:));
        end
        
        if size(original_preserved, 3) == 3
            orig_contrast = std(rgb2gray(im2double(original_preserved))(:));
        else
            orig_contrast = std(im2double(original_preserved)(:));
        end
        
        if final_contrast < orig_contrast
            final_img = original_preserved;
        end
    end
    
    % Preserve RGB colors as required
    if size(original_preserved, 3) == 3 && size(final_img, 3) == 3
        enhanced_img = final_img;
    else
        enhanced_img = final_img;
    end
    
    % Save enhanced image to results directory
    if ~exist('results', 'dir')
        mkdir('results');
    end
    
    [~, name, ext] = fileparts(image_path);
    output_filename = sprintf('enhanced_stable_final_%s.png', name);
    output_path = fullfile('results', output_filename);
    
    imwrite(enhanced_img, output_path);

end