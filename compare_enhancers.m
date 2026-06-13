function compare_enhancers(image_path)
% COMPARE_ENHANCERS - Comprehensive comparison of image enhancement methods
% Compares multiple enhancement techniques with advanced metrics
% Author: Advanced Image Enhancement Research System
% Date: February 2026

    % Input validation
    if nargin < 1 || isempty(image_path)
        error('Usage: compare_enhancers(image_path)');
    end
    
    if ~exist(image_path, 'file')
        error('ERROR: Input image file not found: %s', image_path);
    end
    
    fprintf('\n===============================================================\n');
    fprintf('         COMPREHENSIVE ENHANCEMENT METHODS COMPARISON\n');
    fprintf('===============================================================\n\n');
    
    % Load input image
    fprintf('Loading test image: %s\n', image_path);
    original_img = imread(image_path);
    
    % Convert to grayscale for processing but preserve color for output
    if size(original_img, 3) == 3
        original_gray = im2gray(original_img);
        color_img = original_img;
    else
        original_gray = original_img;
        color_img = repmat(original_img, [1, 1, 3]);
    end
    
    fprintf('Image dimensions: %d x %d\n', size(original_gray, 2), size(original_gray, 1));
    fprintf('Data type: %s\n\n', class(original_gray));
    
    % Apply different enhancement methods
    fprintf('Applying enhancement methods...\n');
    fprintf('----------------------------------------\n');
    
    % Method 1: Histogram Equalization
    fprintf('1. Histogram Equalization...\n');
    try
        histeq_img = histeq(original_gray);
    catch ME
        warning('Histogram Equalization failed: %s', ME.message);
        histeq_img = original_gray;  % Fallback
    end
    
    % Method 2: CLAHE
    fprintf('2. CLAHE...\n');
    try
        clahe_img = adapthisteq(original_gray, 'ClipLimit', 0.02, 'Distribution', 'uniform');
    catch ME
        warning('CLAHE failed: %s', ME.message);
        clahe_img = original_gray;  % Fallback
    end
    
    % Method 3: Basic Auto Contrast (imadjust)
    fprintf('3. Basic Auto Contrast...\n');
    try
        auto_contrast_img = imadjust(original_gray);
    catch ME
        warning('Auto Contrast failed: %s', ME.message);
        auto_contrast_img = original_gray;  % Fallback
    end
    
    % Method 4: Proposed Intelligent Auto Enhancer
    fprintf('4. Proposed Intelligent Auto Enhancer...\n');
    try
        intelligent_img = auto_enhancer(image_path);
        
        % If auto_enhancer returns a color image, convert to grayscale for comparison
        if size(intelligent_img, 3) == 3
            intelligent_img = im2gray(intelligent_img);
        end
    catch ME
        warning('Intelligent Enhancer failed: %s', ME.message);
        intelligent_img = original_gray;  % Fallback
    end
    
    % Compute evaluation metrics
    fprintf('\nComputing evaluation metrics...\n');
    fprintf('----------------------------------------\n');
    
    % Initialize metrics structure
    metrics.histeq.psnr = compute_psnr(original_gray, histeq_img);
    metrics.histeq.mse = compute_mse(original_gray, histeq_img);
    metrics.histeq.ssim = compute_ssim(original_gray, histeq_img);
    
    metrics.clahe.psnr = compute_psnr(original_gray, clahe_img);
    metrics.clahe.mse = compute_mse(original_gray, clahe_img);
    metrics.clahe.ssim = compute_ssim(original_gray, clahe_img);
    
    metrics.auto_contrast.psnr = compute_psnr(original_gray, auto_contrast_img);
    metrics.auto_contrast.mse = compute_mse(original_gray, auto_contrast_img);
    metrics.auto_contrast.ssim = compute_ssim(original_gray, auto_contrast_img);
    
    % Resize intelligent image to match original dimensions for fair comparison
    if ~isequal(size(original_gray), size(intelligent_img))
        fprintf('Note: Resizing enhanced image for fair metric comparison\n');
        intelligent_img_resized = imresize(intelligent_img, size(original_gray));
        metrics.intelligent.psnr = compute_psnr(original_gray, intelligent_img_resized);
        metrics.intelligent.mse = compute_mse(original_gray, intelligent_img_resized);
        metrics.intelligent.ssim = compute_ssim(original_gray, intelligent_img_resized);
    else
        metrics.intelligent.psnr = compute_psnr(original_gray, intelligent_img);
        metrics.intelligent.mse = compute_mse(original_gray, intelligent_img);
        metrics.intelligent.ssim = compute_ssim(original_gray, intelligent_img);
    end
    
    % Display comprehensive comparison
    fprintf('\n===============================================================\n');
    fprintf('                    PERFORMANCE COMPARISON RESULTS\n');
    fprintf('===============================================================\n\n');
    
    fprintf('Method Comparison Results:\n');
    fprintf('------------------------------------------------------------------------\n');
    fprintf('%-20s %-10s %-10s %-10s\n', 'Method', 'PSNR (dB)', 'MSE', 'SSIM');
    fprintf('------------------------------------------------------------------------\n');
    fprintf('%-20s %-10.2f %-10.2f %-10.4f\n', 'Histogram Eq.', ...
            metrics.histeq.psnr, metrics.histeq.mse, metrics.histeq.ssim);
    fprintf('%-20s %-10.2f %-10.2f %-10.4f\n', 'CLAHE', ...
            metrics.clahe.psnr, metrics.clahe.mse, metrics.clahe.ssim);
    fprintf('%-20s %-10.2f %-10.2f %-10.4f\n', 'Auto Contrast', ...
            metrics.auto_contrast.psnr, metrics.auto_contrast.mse, metrics.auto_contrast.ssim);
    fprintf('%-20s %-10.2f %-10.2f %-10.4f\n', 'Intelligent Enhancer', ...
            metrics.intelligent.psnr, metrics.intelligent.mse, metrics.intelligent.ssim);
    fprintf('------------------------------------------------------------------------\n');
    
    % Determine best performer for each metric
    fprintf('\nBest Performance Analysis:\n');
    psnr_values = [metrics.histeq.psnr, metrics.clahe.psnr, metrics.auto_contrast.psnr, metrics.intelligent.psnr];
    mse_values = [metrics.histeq.mse, metrics.clahe.mse, metrics.auto_contrast.mse, metrics.intelligent.mse];
    ssim_values = [metrics.histeq.ssim, metrics.clahe.ssim, metrics.auto_contrast.ssim, metrics.intelligent.ssim];
    
    method_names = {'Histogram Eq.', 'CLAHE', 'Auto Contrast', 'Intelligent Enhancer'};
    
    [best_psnr, best_psnr_idx] = max(psnr_values);
    [best_mse, best_mse_idx] = min(mse_values);
    [best_ssim, best_ssim_idx] = max(ssim_values);
    
    fprintf('  PSNR (Higher = Better): %.2f dB (%s)\n', best_psnr, method_names{best_psnr_idx});
    fprintf('  MSE  (Lower  = Better): %.2f (%s)\n', best_mse, method_names{best_mse_idx});
    fprintf('  SSIM (Higher = Better): %.4f (%s)\n', best_ssim, method_names{best_ssim_idx});
    
    % Overall ranking based on weighted score
    fprintf('\nOverall Ranking (weighted score combining all metrics):\n');
    
    % Normalize metrics for scoring (higher is better for all)
    psnr_norm = (psnr_values - min(psnr_values)) / (max(psnr_values) - min(psnr_values) + eps);
    mse_norm = 1 - ((mse_values - min(mse_values)) / (max(mse_values) - min(mse_values) + eps));  % Invert since lower MSE is better
    ssim_norm = (ssim_values - min(ssim_values)) / (max(ssim_values) - min(ssim_values) + eps);
    
    % Weighted score (PSNR: 30%, MSE: 30%, SSIM: 40%)
    weights = [0.3, 0.3, 0.4];
    overall_scores = weights(1) * psnr_norm + weights(2) * mse_norm + weights(3) * ssim_norm;
    
    % Sort methods by overall score
    [sorted_scores, sort_idx] = sort(overall_scores, 'descend');
    
    fprintf('  Rank | Method                 | Score\n');
    fprintf('  -----|------------------------|------\n');
    for rank = 1:length(sort_idx)
        idx = sort_idx(rank);
        fprintf('  %d    | %-20s | %.3f\n', rank, method_names{idx}, sorted_scores(rank));
    end
    
    % Create results directory if it doesn't exist
    results_dir = 'results';
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
        fprintf('\nCreated results directory: %s\n', results_dir);
    end
    
    % Save comparison results
    comparison_results.original = original_gray;
    comparison_results.histeq = histeq_img;
    comparison_results.clahe = clahe_img;
    comparison_results.auto_contrast = auto_contrast_img;
    comparison_results.intelligent = intelligent_img;
    comparison_results.metrics = metrics;
    comparison_results.method_names = method_names;
    comparison_results.overall_scores = overall_scores;
    comparison_results.timestamp = datestr(now);
    
    save(fullfile(results_dir, 'comparison_results.mat'), 'comparison_results', '-v7');
    fprintf('\nDetailed comparison results saved to: %s/comparison_results.mat\n', results_dir);
    
    % Create comprehensive visualization
    fprintf('\nGenerating comprehensive comparison visualization...\n');
    create_comparison_visualization(original_gray, histeq_img, clahe_img, auto_contrast_img, intelligent_img, metrics, method_names);
    
    % Save comparison image
    [~, name, ~] = fileparts(image_path);
    comparison_filename = sprintf('comparison_%s.png', name);
    comparison_path = fullfile(results_dir, comparison_filename);
    
    % Get the current figure and save it
    fig = gcf;
    exportgraphics(fig, comparison_path, 'Resolution', 300);
    fprintf('Comparison visualization saved to: %s\n', comparison_path);
    
    % Create detailed metrics report
    fprintf('\nGenerating detailed metrics report...\n');
    create_metrics_report(metrics, method_names, overall_scores);
    
    % Save metrics report
    report_filename = sprintf('metrics_report_%s.txt', name);
    report_path = fullfile(results_dir, report_filename);
    fid = fopen(report_path, 'w');
    fprintf(fid, 'Enhancement Methods Comparison Report\n');
    fprintf(fid, '=====================================\n\n');
    fprintf(fid, 'Input Image: %s\n', image_path);
    fprintf(fid, 'Analysis Date: %s\n\n', datestr(now));
    
    fprintf(fid, 'Detailed Metrics:\n');
    fprintf(fid, 'Method               | PSNR (dB) | MSE    | SSIM   |\n');
    fprintf(fid, '---------------------|-----------|--------|--------|\n');
    % Create array of metric structures
    metric_array = {metrics.histeq, metrics.clahe, metrics.auto_contrast, metrics.intelligent};
    for i = 1:length(method_names)
        fprintf(fid, '%-20s | %9.2f | %6.2f | %6.4f |\n', ...
                method_names{i}, ...
                metric_array{i}.psnr, ...
                metric_array{i}.mse, ...
                metric_array{i}.ssim);
    end
    
    fprintf(fid, '\nOverall Rankings:\n');
    for rank = 1:length(sort_idx)
        idx = sort_idx(rank);
        fprintf(fid, '%d. %s (Score: %.3f)\n', rank, method_names{idx}, sorted_scores(rank));
    end
    
    fclose(fid);
    fprintf('Metrics report saved to: %s\n', report_path);
    
    fprintf('\n===============================================================\n');
    fprintf('                    COMPARISON COMPLETED\n');
    fprintf('===============================================================\n\n');
    fprintf('Enhancement methods comparison completed successfully!\n');
    fprintf('Results saved to: %s/ directory\n', results_dir);
    
end

% Helper function to compute PSNR
function psnr_val = compute_psnr(img1, img2)
    if ~isequal(size(img1), size(img2))
        error('Images must have the same dimensions');
    end
    
    mse_val = compute_mse(img1, img2);
    if mse_val == 0
        psnr_val = Inf;
    else
        max_pixel = 255; % Assuming 8-bit images
        psnr_val = 10 * log10((max_pixel^2) / mse_val);
    end
end

% Helper function to compute MSE
function mse_val = compute_mse(img1, img2)
    if ~isequal(size(img1), size(img2))
        error('Images must have the same dimensions');
    end
    
    img1_d = double(img1(:));
    img2_d = double(img2(:));
    mse_val = mean((img1_d - img2_d).^2);
end

% Helper function to compute SSIM
function ssim_val = compute_ssim(img1, img2)
    if ~isequal(size(img1), size(img2))
        error('Images must have the same dimensions');
    end
    
    try
        % Use built-in SSIM function if available
        ssim_val = ssim(img1, img2);
    catch
        % Fallback implementation
        img1 = double(img1);
        img2 = double(img2);
        
        K1 = 0.01;
        K2 = 0.03;
        L = 255;
        
        C1 = (K1 * L)^2;
        C2 = (K2 * L)^2;
        
        % Compute means
        mu1 = conv2(img1, ones(11)/121, 'same');  % Simplified window
        mu2 = conv2(img2, ones(11)/121, 'same');
        
        mu1_sq = mu1 .* mu1;
        mu2_sq = mu2 .* mu2;
        mu1_mu2 = mu1 .* mu2;
        
        % Compute variances and covariance
        sigma1_sq = conv2(img1.*img1, ones(11)/121, 'same') - mu1_sq;
        sigma2_sq = conv2(img2.*img2, ones(11)/121, 'same') - mu2_sq;
        sigma12 = conv2(img1.*img2, ones(11)/121, 'same') - mu1_mu2;
        
        % Compute SSIM
        numerator = (2 * mu1_mu2 + C1) .* (2 * sigma12 + C2);
        denominator = (mu1_sq + mu2_sq + C1) .* (sigma1_sq + sigma2_sq + C2);
        ssim_map = numerator ./ denominator;
        
        ssim_val = mean(ssim_map(:));
    end
end

% Helper function to create comparison visualization
function create_comparison_visualization(original, histeq_img, clahe_img, auto_contrast_img, intelligent_img, metrics, method_names)
    figure('Name', 'Enhancement Methods Comparison', 'Position', [50, 50, 1400, 800]);
    
    % Original image
    subplot(2, 3, 1);
    imshow(original);
    title('Original Image', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Histogram Equalization
    subplot(2, 3, 2);
    imshow(histeq_img);
    title(sprintf('%s\nPSNR: %.2f dB\nSSIM: %.4f', ...
          method_names{1}, metrics.histeq.psnr, metrics.histeq.ssim), 'FontSize', 10);
    
    % CLAHE
    subplot(2, 3, 3);
    imshow(clahe_img);
    title(sprintf('%s\nPSNR: %.2f dB\nSSIM: %.4f', ...
          method_names{2}, metrics.clahe.psnr, metrics.clahe.ssim), 'FontSize', 10);
    
    % Auto Contrast
    subplot(2, 3, 4);
    imshow(auto_contrast_img);
    title(sprintf('%s\nPSNR: %.2f dB\nSSIM: %.4f', ...
          method_names{3}, metrics.auto_contrast.psnr, metrics.auto_contrast.ssim), 'FontSize', 10);
    
    % Intelligent Enhancer
    subplot(2, 3, 5);
    imshow(intelligent_img);
    title(sprintf('%s\nPSNR: %.2f dB\nSSIM: %.4f', ...
          method_names{4}, metrics.intelligent.psnr, metrics.intelligent.ssim), 'FontSize', 10);
    
    % Metrics comparison bar chart
    subplot(2, 3, 6);
    methods_short = {'HistEq', 'CLAHE', 'AutoC', 'Intel'};
    psnr_vals = [metrics.histeq.psnr, metrics.clahe.psnr, metrics.auto_contrast.psnr, metrics.intelligent.psnr];
    ssim_vals = [metrics.histeq.ssim, metrics.clahe.ssim, metrics.auto_contrast.ssim, metrics.intelligent.ssim];
    
    x = 1:4;
    bar_data = [psnr_vals; ssim_vals*100]';
    b = bar(x, bar_data);
    set(b(1), 'FaceColor', [0.8 0.8 1]);  % Light blue for PSNR
    set(b(2), 'FaceColor', [1 0.8 0.8]);  % Light red for SSIM
    
    legend('PSNR (dB)', 'SSIM x100', 'Location', 'northeast');
    xlabel('Methods');
    ylabel('Metric Values');
    title('PSNR and SSIM Comparison', 'FontSize', 10);
    set(gca, 'XTickLabel', methods_short);
    
    sgtitle('Advanced Image Enhancement Methods Comparison', 'FontSize', 16, 'FontWeight', 'bold');
end

% Helper function to create metrics report
function create_metrics_report(metrics, method_names, overall_scores)
    % This function is called from the main function to generate the report
    % Implementation is included in the main function above
end