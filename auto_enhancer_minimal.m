function enhanced_img = auto_enhancer(image_path)
% AUTO_ENHANCER - Clean, Minimal, Stable Image Enhancement
% Single safe enhancement function with gentle processing
% Author: Image Enhancement System
% Date: February 2026

    % Validate input
    if nargin < 1 || isempty(image_path)
        error('Usage: enhanced_img = auto_enhancer(image_path)');
    end
    
    if ~exist(image_path, 'file')
        error('ERROR: Input image file not found: %s', image_path);
    end
    
    fprintf('\n===============================================================\n');
    fprintf('                    MINIMAL AUTO ENHANCER\n');
    fprintf('===============================================================\n\n');
    
    % 1) Load image safely
    fprintf('Loading input image: %s\n', image_path);
    original = imread(image_path);
    img = im2double(original);
    
    % Preserve original for display
    original_display = original;
    
    % 2) Convert to grayscale safely for analysis
    if size(img, 3) == 3
        gray = im2gray(img);
    else
        gray = img;
    end
    
    % 3) Compute image metrics
    mean_brightness = mean(gray(:));
    contrast_val = std(gray(:));
    % Safe noise estimation
    smoothed_gray = imgaussfilt(gray, 1);
    noise_est = std(double(gray(:)) - double(smoothed_gray(:)));
    
    fprintf('Image Analysis:\n');
    fprintf('  Mean Brightness: %.3f\n', mean_brightness);
    fprintf('  Contrast: %.3f\n', contrast_val);
    fprintf('  Noise Estimate: %.3f\n\n', noise_est);
    
    % 4) Apply safe enhancement rules
    
    % A) Brightness correction (mild gamma)
    if mean_brightness < 0.4
        fprintf('Applying mild brightness correction (dark image)\n');
        img = imadjust(img, [], [], 0.8);
    elseif mean_brightness > 0.75
        fprintf('Applying mild brightness correction (bright image)\n');
        img = imadjust(img, [], [], 1.2);
    else
        fprintf('Brightness is adequate, no correction needed\n');
    end
    
    % B) Mild contrast improvement ONLY if low contrast
    if contrast_val < 0.08
        fprintf('Applying mild contrast enhancement (low contrast image)\n');
        if size(img, 3) == 3
            % Apply CLAHE to luminance channel only
            lab_img = rgb2lab(img);
            lab_img(:,:,1) = adapthisteq(lab_img(:,:,1), 'ClipLimit', 0.01);
            img = lab2rgb(lab_img);
        else
            % For grayscale, apply CLAHE directly
            img = adapthisteq(gray, 'ClipLimit', 0.01);
        end
    else
        fprintf('Contrast is adequate, no enhancement needed\n');
    end
    
    % C) Mild denoising ONLY if noise detected
    if noise_est > 0.05
        fprintf('Applying mild denoising (noisy image)\n');
        if size(img, 3) == 3
            img(:,:,1) = imgaussfilt(img(:,:,1), 0.5);
            img(:,:,2) = imgaussfilt(img(:,:,2), 0.5);
            img(:,:,3) = imgaussfilt(img(:,:,3), 0.5);
        else
            img = imgaussfilt(img, 0.5);
        end
    else
        fprintf('Noise level is acceptable, no denoising needed\n');
    end
    
    % D) Very mild sharpening (always safe)
    fprintf('Applying very mild sharpening\n');
    img = imsharpen(img, 'Radius', 1, 'Amount', 0.6);
    
    % 5) Convert back before saving
    enhanced_img = im2uint8(img);
    
    % 6) Display results
    figure('Name', 'Minimal Auto Enhancement Results', 'Position', [100, 100, 1200, 500]);
    
    subplot(1, 2, 1);
    imshow(original_display);
    title('Original Image', 'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1, 2, 2);
    imshow(enhanced_img);
    title('Enhanced Image', 'FontSize', 14, 'FontWeight', 'bold');
    
    sgtitle('Minimal Auto Image Enhancement - Safe & Stable', 'FontSize', 16, 'FontWeight', 'bold');
    
    % 7) Save to results directory
    if ~exist('results', 'dir')
        mkdir('results');
        fprintf('\nCreated results directory\n');
    end
    
    [~, name, ext] = fileparts(image_path);
    output_filename = sprintf('enhanced_%s.png', name);
    output_path = fullfile('results', output_filename);
    
    imwrite(enhanced_img, output_path);
    fprintf('\nEnhanced image saved to: %s\n', output_path);
    fprintf('Minimal auto enhancement completed successfully!\n');
    
end