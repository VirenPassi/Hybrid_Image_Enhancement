function evaluate_multi_defect_system()
% EVALUATE_MULTI_DEFECT_SYSTEM - Evaluate auto_enhancer_multi_defect on multiple test images
% Purpose: Test the multi-defect enhancement system on multiple images
% Author: Multi-Defect Evaluation System
% Date: February 2026

    fprintf('\n===============================================================\n');
    fprintf('         MULTI-DEFECT ENHANCEMENT SYSTEM EVALUATION\n');
    fprintf('===============================================================\n\n');
    
    % Define test images directory
    test_dir = 'test_images';
    if ~exist(test_dir, 'dir')
        error('Test images directory does not exist: %s', test_dir);
    end
    
    % Find test images
    image_extensions = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
    test_images = [];
    
    for i = 1:length(image_extensions)
        files = dir(fullfile(test_dir, image_extensions{i}));
        for j = 1:length(files)
            test_images{end+1} = fullfile(test_dir, files(j).name);
        end
    end
    
    if isempty(test_images)
        error('No test images found in %s directory', test_dir);
    end
    
    % Limit to 5 test images if more exist
    if length(test_images) > 5
        test_images = test_images(1:5);
    end
    
    fprintf('Found %d test images:\n', length(test_images));
    for i = 1:length(test_images)
        fprintf('  %d. %s\n', i, test_images{i});
    end
    fprintf('\n');
    
    % Create results directory
    results_dir = 'results';
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end
    
    % Initialize evaluation metrics
    metrics = struct();
    metrics.image_names = {};
    metrics.psnr_values = [];
    metrics.ssim_values = [];
    metrics.defects_detected = {};
    
    % Process each test image
    for i = 1:length(test_images)
        fprintf('Processing image %d/%d: %s\n', i, length(test_images), test_images{i});
        
        try
            % Get image name without extension for file naming
            [~, img_name, ~] = fileparts(test_images{i});
            
            % Load original image
            original_img = imread(test_images{i});
            original_double = im2double(original_img);
            
            % Apply multi-defect enhancement
            enhanced_img = auto_enhancer_multi_defect(test_images{i});
            enhanced_double = im2double(enhanced_img);
            
            % Handle different image sizes (in case enhancement changes size)
            if size(original_double, 1) ~= size(enhanced_double, 1) || ...
               size(original_double, 2) ~= size(enhanced_double, 2)
                original_resized = imresize(original_double, size(enhanced_double, [1,2]));
            else
                original_resized = original_double;
            end
            
            % Compute PSNR and SSIM
            if size(original_resized, 3) == 3 && size(enhanced_double, 3) == 3
                % For color images, compute metrics on grayscale
                orig_gray = im2gray(original_resized);
                enh_gray = im2gray(enhanced_double);
                
                psnr_val = psnr(enh_gray, orig_gray);
                ssim_val = ssim(enh_gray, orig_gray);
            else
                % For grayscale images
                psnr_val = psnr(enhanced_double, original_resized);
                ssim_val = ssim(enhanced_double, original_resized);
            end
            
            % Store metrics
            metrics.image_names{end+1} = img_name;
            metrics.psnr_values(end+1) = psnr_val;
            metrics.ssim_values(end+1) = ssim_val;
            
            fprintf('  PSNR: %.2f dB\n', psnr_val);
            fprintf('  SSIM: %.4f\n', ssim_val);
            
            % Create comparison visualization
            figure('Name', sprintf('Comparison - %s', img_name), 'Position', [100, 100, 1200, 500]);
            
            subplot(1, 3, 1);
            imshow(original_img);
            title(sprintf('Original: %s', img_name), 'FontSize', 12, 'FontWeight', 'bold');
            
            subplot(1, 3, 2);
            imshow(enhanced_img);
            title('Enhanced (Multi-Defect)', 'FontSize', 12, 'FontWeight', 'bold');
            
            subplot(1, 3, 3);
            % Show difference image (enhanced - original)
            if size(original_img, 3) == 3
                diff_img = abs(double(enhanced_img) - double(original_resized));
            else
                diff_img = abs(double(enhanced_img) - double(original_img));
            end
            diff_img = mat2gray(diff_img);
            imshow(diff_img);
            title(sprintf('Difference (PSNR: %.2f dB, SSIM: %.4f)', psnr_val, ssim_val), ...
                  'FontSize', 10, 'FontWeight', 'bold');
            
            % Save comparison image
            comparison_filename = sprintf('comparison_%s.png', img_name);
            comparison_path = fullfile(results_dir, comparison_filename);
            saveas(gcf, comparison_path);
            fprintf('  Comparison visualization saved to: %s\n', comparison_filename);
            
            % Capture defect detection information from the function
            % Since the function prints to console, we'll record the general fact that
            % defects were analyzed
            fprintf('  Defect analysis completed for: %s\n', img_name);
            fprintf('  Multi-defect enhancement completed successfully.\n\n');
            
        catch ME
            fprintf('  ERROR processing %s: %s\n', test_images{i}, ME.message);
            continue;
        end
    end
    
    % Generate summary report
    fprintf('\n===============================================================\n');
    fprintf('                    EVALUATION SUMMARY\n');
    fprintf('===============================================================\n\n');
    
    fprintf('Processed %d images:\n\n', length(metrics.image_names));
    
    fprintf('Results Table:\n');
    fprintf('--------------------------------------------------------------------\n');
    fprintf('%-20s %-12s %-12s\n', 'Image Name', 'PSNR (dB)', 'SSIM');
    fprintf('--------------------------------------------------------------------\n');
    for i = 1:length(metrics.image_names)
        fprintf('%-20s %-12.2f %-12.4f\n', metrics.image_names{i}, ...
                metrics.psnr_values(i), metrics.ssim_values(i));
    end
    fprintf('--------------------------------------------------------------------\n\n');
    
    % Overall statistics
    avg_psnr = mean(metrics.psnr_values);
    avg_ssim = mean(metrics.ssim_values);
    fprintf('Average PSNR: %.2f dB\n', avg_psnr);
    fprintf('Average SSIM: %.4f\n', avg_ssim);
    
    % Determine success rate
    high_quality_count = sum(metrics.ssim_values > 0.5);  % SSIM > 0.5 considered good
    success_rate = high_quality_count / length(metrics.image_names) * 100;
    fprintf('Success Rate (SSIM > 0.5): %.1f%% (%d/%d images)\n\n', ...
            success_rate, high_quality_count, length(metrics.image_names));
    
    % Save metrics to file
    metrics_filename = 'multi_defect_evaluation_metrics.mat';
    metrics_path = fullfile(results_dir, metrics_filename);
    save(metrics_path, 'metrics');
    fprintf('Detailed metrics saved to: %s\n', metrics_filename);
    
    % Create summary visualization
    create_summary_visualization(metrics, results_dir);
    
    fprintf('\nMulti-defect enhancement system evaluation completed successfully!\n');
    fprintf('All results saved to: %s/ directory\n', results_dir);
    
end

function create_summary_visualization(metrics, results_dir)
% Helper function to create summary visualization of evaluation results

    % Create PSNR and SSIM comparison plot
    figure('Name', 'Multi-Defect System Evaluation Summary', 'Position', [100, 100, 1000, 600]);
    
    subplot(2, 2, 1);
    bar(metrics.psnr_values);
    title('PSNR Values by Image', 'FontWeight', 'bold');
    xlabel('Image Index');
    ylabel('PSNR (dB)');
    grid on;
    
    subplot(2, 2, 2);
    bar(metrics.ssim_values);
    title('SSIM Values by Image', 'FontWeight', 'bold');
    xlabel('Image Index');
    ylabel('SSIM');
    ylim([0, 1]);
    grid on;
    
    subplot(2, 2, 3);
    plot(metrics.psnr_values, metrics.ssim_values, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
    title('PSNR vs SSIM Correlation', 'FontWeight', 'bold');
    xlabel('PSNR (dB)');
    ylabel('SSIM');
    grid on;
    
    subplot(2, 2, 4);
    hold on;
    plot(metrics.psnr_values, 'b-o', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'PSNR');
    plot(metrics.ssim_values * max(metrics.psnr_values), 'r-s', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'SSIM (scaled)');
    title('Normalized Comparison', 'FontWeight', 'bold');
    xlabel('Image Index');
    ylabel('Value');
    legend('show');
    grid on;
    
    % Save summary plot
    summary_plot_path = fullfile(results_dir, 'evaluation_summary_plot.png');
    saveas(gcf, summary_plot_path);
    
    fprintf('Summary visualization saved to: evaluation_summary_plot.png\n');
end