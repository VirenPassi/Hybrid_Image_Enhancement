function system_validation_suite()
% SYSTEM_VALIDATION_SUITE - Validate auto_enhancer_final for multiple defect types
% Automated testing suite for final MATLAB auto enhancer
% Author: Validation System
% Date: February 2026

    fprintf('\n===============================================================\n');
    fprintf('         AUTO ENHANCER FINAL - VALIDATION SUITE\n');
    fprintf('===============================================================\n\n');
    
    % Test images and expected defect types
    test_images = {
        'test_images/salt and pepper lena.jpg', 'salt_pepper';
        'test_images/blurred_image.jpg', 'blur';
        'test_images/low_contrast_image.png', 'low_contrast';
        'test_images/night_street.jpg', 'low_brightness';
        'test_images/original lena.jpg', 'clean'
    };
    
    % Initialize results table
    results = struct();
    results.image_names = {};
    results.test_types = {};
    results.status = {};
    results.ssim_values = [];
    results.psnr_values = [];
    results.notes = {};
    
    % Process each test image
    for i = 1:size(test_images, 1)
        image_path = test_images{i, 1};
        test_type = test_images{i, 2};
        
        fprintf('Testing %s (%s test)...\n', image_path, test_type);
        
        % Check if image exists
        if ~exist(image_path, 'file')
            fprintf('  SKIP: Image file not found\n\n');
            continue;
        end
        
        try
            % Load original image
            original = imread(image_path);
            original_double = im2double(original);
            
            % Run auto_enhancer_final
            enhanced = auto_enhancer_final(image_path);
            enhanced_double = im2double(enhanced);
            
            % Handle different image sizes
            if size(original_double, 1) ~= size(enhanced_double, 1) || ...
               size(original_double, 2) ~= size(enhanced_double, 2)
                original_resized = imresize(original_double, size(enhanced_double, [1,2]));
            else
                original_resized = original_double;
            end
            
            % Compute quality metrics
            if size(original_resized, 3) == 3 && size(enhanced_double, 3) == 3
                % For color images, compute metrics on grayscale
                orig_gray = im2gray(original_resized);
                enh_gray = im2gray(enhanced_double);
                
                ssim_val = ssim(enh_gray, orig_gray);
                psnr_val = psnr(enh_gray, orig_gray);
            else
                % For grayscale images
                ssim_val = ssim(enhanced_double, original_resized);
                psnr_val = psnr(enhanced_double, original_resized);
            end
            
            % Perform specific defect tests
            test_result = perform_defect_test(image_path, original_double, enhanced_double, test_type);
            
            % Store results
            [~, img_name, ~] = fileparts(image_path);
            results.image_names{end+1} = img_name;
            results.test_types{end+1} = test_type;
            results.status{end+1} = test_result.status;
            results.ssim_values(end+1) = ssim_val;
            results.psnr_values(end+1) = psnr_val;
            results.notes{end+1} = test_result.notes;
            
            fprintf('  Result: %s | SSIM: %.4f | PSNR: %.2f dB | %s\n\n', ...
                    test_result.status, ssim_val, psnr_val, test_result.notes);
            
        catch ME
            fprintf('  ERROR: %s\n\n', ME.message);
            
            % Store error result
            [~, img_name, ~] = fileparts(image_path);
            results.image_names{end+1} = img_name;
            results.test_types{end+1} = test_type;
            results.status{end+1} = 'FAIL';
            results.ssim_values(end+1) = NaN;
            results.psnr_values(end+1) = NaN;
            results.notes{end+1} = sprintf('Error: %s', ME.message);
        end
    end
    
    % Display final results table
    display_results_table(results);
    
    % Summary statistics
    fprintf('\n===============================================================\n');
    fprintf('                    VALIDATION SUMMARY\n');
    fprintf('===============================================================\n\n');
    
    total_tests = length(results.status);
    passed_tests = sum(strcmp(results.status, 'PASS'));
    failed_tests = sum(strcmp(results.status, 'FAIL'));
    
    fprintf('Total Tests: %d\n', total_tests);
    fprintf('Passed: %d (%.1f%%)\n', passed_tests, passed_tests/total_tests*100);
    fprintf('Failed: %d (%.1f%%)\n\n', failed_tests, failed_tests/total_tests*100);
    
    % Overall assessment
    if passed_tests == total_tests
        fprintf('✅ ALL TESTS PASSED - System validation successful!\n');
    elseif passed_tests >= total_tests * 0.8
        fprintf('⚠️  MOST TESTS PASSED - System generally functional\n');
    else
        fprintf('❌ TOO MANY FAILURES - System requires improvement\n');
    end
    
    fprintf('\nValidation suite completed.\n');
    
end

function test_result = perform_defect_test(image_path, original, enhanced, test_type)
% Perform specific defect-type testing

    test_result.status = 'FAIL';
    test_result.notes = '';
    
    switch test_type
        case 'salt_pepper'
            % Measure extreme pixel ratio before and after
            if size(original, 3) == 3
                orig_gray = im2gray(original);
                enh_gray = im2gray(enhanced);
            else
                orig_gray = original;
                enh_gray = enhanced;
            end
            
            orig_ratio = sum(orig_gray(:)==0 | orig_gray(:)==1)/numel(orig_gray);
            enh_ratio = sum(enh_gray(:)==0 | enh_gray(:)==1)/numel(enh_gray);
            
            if enh_ratio < orig_ratio
                test_result.status = 'PASS';
                test_result.notes = sprintf('Salt&pepper ratio: %.4f → %.4f', orig_ratio, enh_ratio);
            else
                test_result.notes = sprintf('Salt&pepper ratio not improved: %.4f → %.4f', orig_ratio, enh_ratio);
            end
            
        case 'blur'
            % Compute variance of Laplacian before and after
            if size(original, 3) == 3
                orig_gray = im2gray(original);
                enh_gray = im2gray(enhanced);
            else
                orig_gray = original;
                enh_gray = enhanced;
            end
            
            orig_lap = del2(orig_gray);
            enh_lap = del2(enh_gray);
            orig_var = var(orig_lap(:));
            enh_var = var(enh_lap(:));
            
            if enh_var > orig_var
                test_result.status = 'PASS';
                test_result.notes = sprintf('Laplacian variance: %.6f → %.6f', orig_var, enh_var);
            else
                test_result.notes = sprintf('Laplacian variance not improved: %.6f → %.6f', orig_var, enh_var);
            end
            
        case 'low_contrast'
            % Compare intensity standard deviation
            if size(original, 3) == 3
                orig_gray = im2gray(original);
                enh_gray = im2gray(enhanced);
            else
                orig_gray = original;
                enh_gray = enhanced;
            end
            
            orig_std = std(orig_gray(:));
            enh_std = std(enh_gray(:));
            
            if enh_std > orig_std
                test_result.status = 'PASS';
                test_result.notes = sprintf('Contrast std: %.4f → %.4f', orig_std, enh_std);
            else
                test_result.notes = sprintf('Contrast std not improved: %.4f → %.4f', orig_std, enh_std);
            end
            
        case 'low_brightness'
            % Compare mean intensity
            if size(original, 3) == 3
                orig_gray = im2gray(original);
                enh_gray = im2gray(enhanced);
            else
                orig_gray = original;
                enh_gray = enhanced;
            end
            
            orig_mean = mean(orig_gray(:));
            enh_mean = mean(enh_gray(:));
            
            if enh_mean > orig_mean
                test_result.status = 'PASS';
                test_result.notes = sprintf('Brightness mean: %.4f → %.4f', orig_mean, enh_mean);
            else
                test_result.notes = sprintf('Brightness mean not improved: %.4f → %.4f', orig_mean, enh_mean);
            end
            
        case 'clean'
            % For clean image, check that SSIM > 0.9 (no major degradation)
            if size(original, 3) == 3 && size(enhanced, 3) == 3
                orig_gray = im2gray(original);
                enh_gray = im2gray(enhanced);
                ssim_val = ssim(enh_gray, orig_gray);
            else
                ssim_val = ssim(enhanced, original);
            end
            
            if ssim_val > 0.9
                test_result.status = 'PASS';
                test_result.notes = sprintf('Clean image preserved (SSIM: %.4f)', ssim_val);
            else
                test_result.notes = sprintf('Clean image degraded (SSIM: %.4f < 0.9)', ssim_val);
            end
            
        otherwise
            test_result.notes = 'Unknown test type';
    end
    
end

function display_results_table(results)
% Display structured results table

    fprintf('\n===============================================================\n');
    fprintf('                    VALIDATION RESULTS TABLE\n');
    fprintf('===============================================================\n\n');
    
    fprintf('%-25s %-15s %-8s %-8s %s\n', 'Image', 'Test Type', 'Status', 'SSIM', 'Notes');
    fprintf('%s\n', repmat('-', 1, 80));
    
    for i = 1:length(results.image_names)
        if isnan(results.ssim_values(i))
            ssim_str = 'N/A';
        else
            ssim_str = sprintf('%.4f', results.ssim_values(i));
        end
        
        fprintf('%-25s %-15s %-8s %-8s %s\n', ...
                results.image_names{i}, ...
                results.test_types{i}, ...
                results.status{i}, ...
                ssim_str, ...
                results.notes{i});
    end
    
    fprintf('%s\n', repmat('-', 1, 80));
    
end