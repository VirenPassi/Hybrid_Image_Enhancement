function enhanced_img = auto_enhancer_perceptual(image_path)
% AUTO_ENHANCER_PERCEPTUAL - Perceptual AI Enhancement System
% Makes images visually better similar to PicsArt/Cutout auto enhancement
% Author: Perceptual Enhancement System
% Date: February 2026

    % Validate input
    if nargin < 1 || isempty(image_path)
        error('Usage: enhanced_img = auto_enhancer_perceptual(image_path)');
    end
    
    if ~exist(image_path, 'file')
        error('ERROR: Input image file not found: %s', image_path);
    end
    
    fprintf('\n===============================================================\n');
    fprintf('              PERCEPTUAL AI ENHANCEMENT SYSTEM\n');
    fprintf('===============================================================\n\n');
    
    % Load image safely
    fprintf('Loading input image: %s\n', image_path);
    original = imread(image_path);
    img = im2double(original);
    
    % Preserve original for display
    original_display = original;
    
    % Super-resolution equivalent: Enhanced bicubic upsampling
    % Since srnet/superres not available, use enhanced upsampling approach
    [height, width, ~] = size(img);
    
    fprintf('Original image size: %d x %d\n', width, height);
    
    % Apply perceptual super-resolution equivalent
    if height < 400 || width < 400  % Low resolution detected
        fprintf('Applying perceptual super-resolution equivalent...\n');
        img_sr = imresize(img, 2, 'bicubic');  % Double the size with bicubic
        fprintf('Super-resolved to: %d x %d\n', size(img_sr, 2), size(img_sr, 1));
    else
        img_sr = img;  % Use original if already high resolution
    end
    
    % Apply mild enhancement for perceptual quality
    fprintf('Applying perceptual enhancement...\n');
    
    % Apply imadjust for better contrast and brightness
    if size(img_sr, 3) == 3
        % Process each channel separately to preserve color
        img_sr(:,:,1) = imadjust(img_sr(:,:,1));
        img_sr(:,:,2) = imadjust(img_sr(:,:,2));
        img_sr(:,:,3) = imadjust(img_sr(:,:,3));
    else
        img_sr = imadjust(img_sr);
    end
    
    % Apply perceptual sharpening
    img_sr = imsharpen(img_sr, 'Radius', 2, 'Amount', 1.2);
    
    % Final perceptual enhancement - slight saturation boost for vividness
    if size(img_sr, 3) == 3
        % Convert to LAB to enhance luminance without affecting color balance too much
        lab_img = rgb2lab(img_sr);
        lab_img(:,:,1) = lab_img(:,:,1) * 1.05;  % Slightly boost luminance
        lab_img(:,:,1) = max(0, min(100, lab_img(:,:,1)));  % Clamp to valid range
        img_sr = lab2rgb(lab_img);
    end
    
    % Convert back to uint8
    enhanced_img = im2uint8(img_sr);
    
    % Display results
    figure('Name', 'Perceptual AI Enhancement Results', 'Position', [100, 100, 1200, 500]);
    
    subplot(1, 2, 1);
    imshow(original_display);
    title('Original Image', 'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1, 2, 2);
    imshow(enhanced_img);
    title('Perceptual Enhanced', 'FontSize', 14, 'FontWeight', 'bold');
    
    sgtitle('Perceptual AI Enhancement - Visually Better Results', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Save to results directory
    if ~exist('results', 'dir')
        mkdir('results');
        fprintf('\nCreated results directory\n');
    end
    
    [~, name, ext] = fileparts(image_path);
    output_filename = sprintf('enhanced_perceptual_%s.png', name);
    output_path = fullfile('results', output_filename);
    
    imwrite(enhanced_img, output_path);
    fprintf('\nPerceptual enhanced image saved to: %s\n', output_path);
    fprintf('Perceptual AI enhancement completed successfully!\n');
    
end