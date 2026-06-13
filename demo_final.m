function demo_final()
% DEMO_FINAL - Complete demonstration of advanced intelligent auto enhancer
% Runs full workflow: analysis -> enhancement -> comparison
% Author: Advanced Image Enhancement Research System
% Date: February 2026

    % Clear workspace and close figures
    clearvars;
    close all;
    
    fprintf('\n===============================================================\n');
    fprintf('         ADVANCED INTELLIGENT AUTO ENHANCER - DEMONSTRATION\n');
    fprintf('===============================================================\n\n');
    
    fprintf('System Ready - Running Intelligent Adaptive Auto Enhancer\n\n');
    
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
    
    % Use default test image - only for demonstration
    % In production, users should call auto_enhancer(image_path) directly
    image_path = 'test_images/test_image.png';
    
    % Validate image path
    if isempty(image_path) || ~exist(image_path, 'file')
        % Create a synthetic test image if no valid image provided
        fprintf('No valid image found. Creating synthetic test image...\n');
        image_path = create_synthetic_test_image();
    end
    
    fprintf('\nSelected image: %s\n\n', image_path);
    
    % DEMO PHASE 1: Image Analysis
    fprintf('===============================================================\n');
    fprintf('                    PHASE 1: IMAGE ANALYSIS\n');
    fprintf('===============================================================\n\n');
    
    original_img = imread(image_path);
    gray_img = im2gray(original_img);
    
    [brightness, contrast, entropy, edge_density, noise_level] = analyze_image(gray_img);
    
    % Package analysis results
    analysis_results.brightness = brightness;
    analysis_results.contrast = contrast;
    analysis_results.entropy = entropy;
    analysis_results.edge_density = edge_density;
    analysis_results.noise_level = noise_level;
    
    fprintf('\nAnalysis results stored for enhancement pipeline.\n\n');
    
    % DEMO PHASE 2: Enhancement
    fprintf('===============================================================\n');
    fprintf('                 PHASE 2: INTELLIGENT ENHANCEMENT\n');
    fprintf('===============================================================\n\n');
    
    % Apply intelligent enhancement
    enhanced_img = auto_enhancer(image_path);
    
    fprintf('\nEnhancement completed. Results saved to results/ directory.\n\n');
    
    % DEMO PHASE 3: Comparison
    fprintf('===============================================================\n');
    fprintf('                   PHASE 3: METHOD COMPARISON\n');
    fprintf('===============================================================\n\n');
    
    % Run comprehensive comparison
    compare_enhancers(image_path);
    
    % DEMO PHASE 4: System Summary
    fprintf('\n===============================================================\n');
    fprintf('                    DEMONSTRATION SUMMARY\n');
    fprintf('===============================================================\n\n');
    
    fprintf('ADVANCED INTELLIGENT AUTO ENHANCER WORKFLOW:\n');
    fprintf('1. ✓ Image Analysis: Comprehensive quality metrics computed\n');
    fprintf('2. ✓ Adaptive Decision Engine: Dynamic pipeline construction\n');
    fprintf('3. ✓ Multi-Stage Enhancement: Quality-aware processing\n');
    fprintf('4. ✓ Comprehensive Comparison: 4-method evaluation\n\n');
    
    fprintf('UNIQUE FEATURES DEMONSTRATED:\n');
    fprintf('• Adaptive decision-making based on image analysis\n');
    fprintf('• Dynamic pipeline construction (not fixed)\n');
    fprintf('• Quality-aware enhancement operations\n');
    fprintf('• Multi-metric evaluation (PSNR, SSIM, MSE)\n');
    fprintf('• Automated result saving and visualization\n\n');
    
    fprintf('RESULTS LOCATION:\n');
    fprintf('• Enhanced images: results/enhanced_*.png\n');
    fprintf('• Comparison images: results/comparison_*.png\n');
    fprintf('• Detailed metrics: results/metrics_report_*.txt\n');
    fprintf('• Comparison data: results/comparison_results.mat\n\n');
    
    fprintf('===============================================================\n');
    fprintf('                 DEMONSTRATION COMPLETED\n');
    fprintf('===============================================================\n\n');
    
    fprintf('The Advanced Intelligent Auto Enhancer is ready for use!\n');
    fprintf('Try running individual components:\n');
    fprintf('  analyze_image(your_image)\n');
    fprintf('  auto_enhancer(your_image_path)\n');
    fprintf('  compare_enhancers(your_image_path)\n\n');

end

% Helper function to find a test image
function test_image = find_test_image()
    % Look for common test image locations
    possible_paths = {
        'test_images/', 
        '../test_images/',
        'data/',
        'images/',
        'samples/'
    };
    
    extensions = {'*.jpg', '*.png', '*.bmp', '*.tif', '*.tiff'};
    
    for i = 1:length(possible_paths)
        if exist(possible_paths{i}, 'dir')
            for j = 1:length(extensions)
                files = dir(fullfile(possible_paths{i}, extensions{j}));
                if ~isempty(files)
                    test_image = fullfile(possible_paths{i}, files(1).name);
                    return;
                end
            end
        end
    end
    
    % Check current directory
    for j = 1:length(extensions)
        files = dir(extensions{j});
        if ~isempty(files)
            test_image = files(1).name;
            return;
        end
    end
    
    % No test image found
    test_image = '';
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
    
    % Add noise to some areas
    noise_mask = synthetic_img(170:200, 100:130);
    noise = uint8(20 * randn(31, 31));
    synthetic_img(170:200, 100:130) = uint8(max(0, min(255, double(noise_mask) + noise)));
    
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