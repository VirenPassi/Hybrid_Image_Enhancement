function demo_stable_final()
% DEMO_STABLE_FINAL - Demonstration of FINAL Stable Adaptive System
% Runs complete workflow: analysis -> enhancement -> comparison for the new stable system
% Author: Advanced Image Enhancement Research System
% Date: February 2026

    % Clear workspace and close figures
    clearvars;
    close all;
    
    fprintf('\n===============================================================\n');
    fprintf('         FINAL STABLE ADAPTIVE SYSTEM - DEMONSTRATION\n');
    fprintf('===============================================================\n\n');
    
    fprintf('System Ready - Running FINAL Stable Adaptive Auto Enhancer\n\n');
    
    % Check Image Processing Toolbox
    if license('test', 'Image_Toolbox')
        fprintf('✓ Image Processing Toolbox: Available\n');
    else
        error('✗ Image Processing Toolbox: Required but not available');
    end
    
    % Create results directory if it doesn't exist
    if ~exist('results', 'dir')
        mkdir('results');
    end
    
    % Define test images to demonstrate the system
    test_images = {
        'test_images/test_image.png';
        'test_images/blurred_image.jpg'; 
        'test_images/low_contrast_image.png';
        'test_images/night_street.jpg';
        'test_images/salt and pepper lena.jpg';
        'test_images/original lena.jpg'
    };
    
    % Try to find a valid test image
    image_path = '';
    for i = 1:length(test_images)
        if exist(test_images{i}, 'file')
            image_path = test_images{i};
            break;
        end
    end
    
    % If no test image found in predefined list, look for any image in test_images folder
    if isempty(image_path)
        test_files = dir('test_images/*.*');
        for i = 1:length(test_files)
            if any(strcmp(lower(test_files(i).name), {'.jpg', '.jpeg', '.png', '.bmp', '.tiff', '.tif'}))
                image_path = ['test_images/' test_files(i).name];
                break;
            end
        end
    end
    
    % If still no image found, create a synthetic one
    if isempty(image_path)
        fprintf('No valid test image found. Creating synthetic test image...\n');
        image_path = create_synthetic_test_image();
    end
    
    fprintf('\nSelected image for demonstration: %s\n\n', image_path);
    
    % DEMO PHASE 1: Image Analysis
    fprintf('===============================================================\n');
    fprintf('                    PHASE 1: IMAGE ANALYSIS\n');
    fprintf('===============================================================\n\n');
    
    original_img = imread(image_path);
    gray_img = im2gray(original_img);
    
    % Perform the same analysis as the stable system
    [blur_metric, sp_ratio, brightness, contrast] = analyze_image_stable(gray_img);
    
    fprintf('Analysis results:\n');
    fprintf('  Blur (Variance of Laplacian): %.6f\n', blur_metric);
    fprintf('  Salt & Pepper Ratio: %.4f\n', sp_ratio);
    fprintf('  Brightness (Mean Intensity): %.4f\n', brightness);
    fprintf('  Contrast (Std Deviation): %.4f\n\n', contrast);
    
    % DEMO PHASE 2: Enhancement with FINAL STABLE SYSTEM
    fprintf('===============================================================\n');
    fprintf('               PHASE 2: FINAL STABLE ENHANCEMENT\n');
    fprintf('===============================================================\n\n');
    
    % Apply the FINAL STABLE ADAPTIVE SYSTEM
    enhanced_img = auto_enhancer_stable_final(image_path);
    
    fprintf('\nEnhancement completed. Results saved to results/ directory.\n\n');
    
    % DEMO PHASE 3: System Summary
    fprintf('\n===============================================================\n');
    fprintf('                    DEMONSTRATION SUMMARY\n');
    fprintf('===============================================================\n\n');
    
    fprintf('FINAL STABLE ADAPTIVE SYSTEM FEATURES:\n');
    fprintf('1. ✓ Defect Detection: Blur, Salt&Pepper, Brightness, Contrast\n');
    fprintf('2. ✓ Targeted Corrections: Only what is needed\n');
    fprintf('3. ✓ Perceptual Polish: Only when appropriate\n');
    fprintf('4. ✓ Quality Safeguards: SSIM validation\n');
    fprintf('5. ✓ Guarantees: No darker images, no reduced contrast, etc.\n');
    fprintf('6. ✓ Side-by-side comparison\n\n');
    
    fprintf('SPECIFIC IMPLEMENTATION:\n');
    fprintf('• Blur detection: Variance of Laplacian\n');
    fprintf('• Salt & pepper: Extreme pixel ratio\n');
    fprintf('• Brightness: Mean intensity measurement\n');
    fprintf('• Contrast: Standard deviation\n');
    fprintf('• Corrections applied only when needed\n');
    fprintf('• Safeguards prevent degradation\n\n');
    
    fprintf('RESULTS LOCATION:\n');
    fprintf('• Enhanced image: results/enhanced_stable_final_*.png\n\n');
    
    fprintf('===============================================================\n');
    fprintf('              FINAL STABLE SYSTEM DEMONSTRATION COMPLETED\n');
    fprintf('===============================================================\n\n');
    
    fprintf('The FINAL STABLE ADAPTIVE SYSTEM is ready for use!\n');
    fprintf('Try running: auto_enhancer_stable_final(your_image_path)\n\n');

end

% Helper function to perform analysis like the stable system
function [blur_metric, sp_ratio, brightness, contrast] = analyze_image_stable(gray_img)
    % Convert to double for analysis
    gray_double = im2double(gray_img);
    
    % Blur detection: variance of Laplacian
    laplacian_kernel = [0 -1 0; -1 4 -1; 0 -1 0];
    laplacian_filtered = conv2(double(gray_double), laplacian_kernel, 'same');
    blur_metric = var(laplacian_filtered(:));
    
    % Salt & pepper detection: extreme pixel ratio
    sp_ratio = sum(gray_double(:) == 0 | gray_double(:) == 1) / numel(gray_double);
    
    % Brightness detection: mean intensity
    brightness = mean(gray_double(:));
    
    % Contrast detection: std deviation
    contrast = std(gray_double(:));
end

% Helper function to create synthetic test image
function image_path = create_synthetic_test_image()
    fprintf('Creating synthetic test image with various quality challenges...\n');
    
    % Create an image with multiple quality issues
    img_size = 300;
    synthetic_img = zeros(img_size, img_size, 'uint8');
    
    % Add different regions with various challenges
    % Low brightness region
    synthetic_img(50:150, 50:150) = uint8(30 * ones(101, 101));
    
    % Medium brightness region
    synthetic_img(160:250, 160:250) = uint8(120 * ones(91, 91));
    
    % Add some high contrast edges
    synthetic_img(80:85, 80:120) = 200;  % Vertical edge
    synthetic_img(100:140, 100:105) = 200;  % Horizontal edge
    
    % Add low contrast area
    low_contrast_region = 100 + 5 * randn(50, 50);
    low_contrast_region = uint8(max(0, min(255, low_contrast_region)));
    synthetic_img(200:249, 50:99) = low_contrast_region;
    
    % Add salt and pepper noise to some areas
    [rows, cols] = size(synthetic_img);
    num_sp = floor(0.02 * rows * cols);  % 2% salt and pepper noise
    sp_locations = randi([1, rows], [num_sp, 1]); sp_values = rand(num_sp, 1);
    for i = 1:num_sp
        r = sp_locations(i);
        c = randi([1, cols]);
        if sp_values(i) < 0.5
            synthetic_img(r, c) = 0;      % Salt
        else
            synthetic_img(r, c) = 255;    % Pepper
        end
    end
    
    % Add low entropy (smooth) region
    synthetic_img(250:290, 200:280) = 180;
    
    % Create test_images directory if needed
    if ~exist('test_images', 'dir')
        mkdir('test_images');
    end
    
    image_path = 'test_images/synthetic_test.png';
    imwrite(synthetic_img, image_path);
    
    fprintf('Synthetic test image created: %s\n', image_path);
end