function enhanced_img = auto_enhancer(image_path)
% AUTO_ENHANCER - Advanced Intelligent Multi-Stage Auto Image Enhancer
% Automatically analyzes image quality and dynamically constructs enhancement pipeline
% Author: Advanced Image Enhancement Research System
% Date: February 2026

    % Validate input
    if nargin < 1 || isempty(image_path)
        error('Usage: enhanced_img = auto_enhancer(image_path)');
    end
    
    if ~exist(image_path, 'file')
        error('ERROR: Input image file not found: %s', image_path);
    end
    
    fprintf('\n===============================================================\n');
    fprintf('         ADVANCED INTELLIGENT AUTO IMAGE ENHANCER\n');
    fprintf('===============================================================\n\n');
    
    % Load and preprocess image
    fprintf('Loading input image: %s\n', image_path);
    original_img = imread(image_path);
    
    % Convert to grayscale for analysis (but preserve color for output)
    if size(original_img, 3) == 3
        gray_img = im2gray(original_img);
        color_img = original_img;
    else
        gray_img = original_img;
        color_img = repmat(original_img, [1, 1, 3]);
    end
    
    fprintf('Image dimensions: %d x %d x %d\n', size(color_img, 2), size(color_img, 1), size(color_img, 3));
    fprintf('Data type: %s\n\n', class(gray_img));
    
    % Analyze image quality
    fprintf('Analyzing image quality...\n');
    [brightness, contrast, entropy, edge_density, noise_level, low_resolution, blocky] = analyze_image(gray_img);
    
    fprintf('Image Quality Analysis Results:\n');
    fprintf('  Brightness (mean intensity): %.2f\n', brightness);
    fprintf('  Contrast (std deviation): %.2f\n', contrast);
    fprintf('  Entropy (texture richness): %.4f\n', entropy);
    fprintf('  Edge Density: %.4f\n', edge_density);
    fprintf('  Noise Level: %.4f\n', noise_level);
    if low_resolution
        low_res_str = 'YES';
    else
        low_res_str = 'NO';
    end
    
    if blocky
        blocky_str = 'YES';
    else
        blocky_str = 'NO';
    end
    
    fprintf('  Low Resolution: %s\n', low_res_str);
    fprintf('  Blocky/Pixelated: %s\n\n', blocky_str);
    
    % Determine enhancement thresholds based on analysis
    bright_threshold = 100;  % Low brightness threshold
    contrast_threshold = 40;  % Low contrast threshold
    entropy_threshold = 6.5;  % Low entropy threshold
    edge_threshold = 0.15;    % Low edge density threshold
    noise_threshold = 0.05;   % High noise threshold
    
    % Package analysis results for enhanced pipeline
    analysis_results.brightness = brightness;
    analysis_results.contrast = contrast;
    analysis_results.entropy = entropy;
    analysis_results.edge_density = edge_density;
    analysis_results.noise_level = noise_level;
    analysis_results.low_resolution = low_resolution;
    analysis_results.blocky = blocky;
        
    % Apply enhanced pipeline with new low-quality image capabilities
    fprintf('Constructing enhanced adaptive enhancement pipeline...\n');
    fprintf('---------------------------------------------\n');
        
    [enhanced_img, applied_operations] = enhancement_pipeline(color_img, analysis_results);
    
    % Display summary of applied operations
    fprintf('\n===============================================================\n');
    fprintf('                    ENHANCEMENT PIPELINE SUMMARY\n');
    fprintf('===============================================================\n\n');
    
    if ~isempty(applied_operations)
        fprintf('Operations Applied (%d total):\n', length(applied_operations));
        for i = 1:length(applied_operations)
            fprintf('  %d. %s\n', i, applied_operations{i});
        end
    else
        fprintf('No enhancement operations were applied.\n');
        fprintf('Image was already of good quality based on analysis.\n');
    end
    
    % Create results directory if it doesn't exist
    results_dir = 'results';
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
        fprintf('\nCreated results directory: %s\n', results_dir);
    end
    
    % Save enhanced image
    [~, name, ext] = fileparts(image_path);
    output_filename = sprintf('enhanced_%s.png', name);
    output_path = fullfile(results_dir, output_filename);
    
    imwrite(enhanced_img, output_path);
    fprintf('\nEnhanced image saved to: %s\n', output_path);
    
    % Display before/after comparison
    figure('Name', 'Auto Enhancement Results', 'Position', [100, 100, 1200, 500]);
    
    subplot(1, 2, 1);
    imshow(color_img);
    title('Original Image', 'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1, 2, 2);
    imshow(enhanced_img);
    title('Enhanced Image', 'FontSize', 14, 'FontWeight', 'bold');
    
    sgtitle('Advanced Intelligent Auto Image Enhancement - Enhanced Pipeline', 'FontSize', 16, 'FontWeight', 'bold');
    
    fprintf('\nAdvanced auto enhancement completed successfully!\n');
    fprintf('Enhanced image quality metrics:\n');
    
    % Calculate final quality metrics
    enhanced_gray = im2gray(enhanced_img);
    final_brightness = mean(mean(double(enhanced_gray)));
    final_contrast = std(double(enhanced_gray(:)));
    
    fprintf('  Final Brightness: %.2f\n', final_brightness);
    fprintf('  Final Contrast: %.2f\n', final_contrast);
    
end