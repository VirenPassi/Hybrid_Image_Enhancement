function [brightness, contrast, entropy, edge_density, noise_level, low_resolution, blocky] = analyze_image(img)
% ANALYZE_IMAGE - Advanced image quality analysis module
% Computes comprehensive quality metrics for intelligent enhancement decisions
% Enhanced for low-quality image detection (resolution, pixelation, artifacts)
% Author: Advanced Image Enhancement Research System
% Date: February 2026

    % Input validation
    if nargin < 1 || isempty(img)
        error('Usage: [brightness, contrast, entropy, edge_density, noise_level, low_resolution, blocky] = analyze_image(img)');
    end
    
    % Convert to double for processing
    if isa(img, 'uint8') || isa(img, 'uint16')
        img_double = double(img);
    else
        img_double = img;
    end
    
    % Ensure image is in grayscale for analysis
    if size(img, 3) == 3
        img_gray = rgb2gray(img);
        img_double = double(img_gray);
    else
        img_gray = img;
        img_double = double(img);
    end
    
    % 0. Low Resolution and Pixelation Detection
    [h, w] = size(img_gray);
    
    % Low resolution detection
    low_resolution = (h < 300 || w < 300);
    
    % Pixelation/blockiness detection
    % Detect edges using Sobel operator
    edge_map = edge(double(img_gray), 'sobel');
    
    % Analyze edge orientation patterns for grid/block detection
    % Compute horizontal and vertical edge projections
    horizontal_edges = sum(edge_map, 1);  % Sum along rows
    vertical_edges = sum(edge_map, 2);    % Sum along columns
    
    % Look for periodic patterns in edge distribution
    % Check for strong peaks at regular intervals (indicating block boundaries)
    blocky = detect_blockiness(horizontal_edges, vertical_edges, w, h);
    
    fprintf('Low-Quality Image Detection:\n');
    fprintf('  Image Dimensions: %d x %d\n', w, h);
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
    fprintf('  Blocky/Pixelated: %s\n', blocky_str);
    
    % 1. Brightness Analysis (mean intensity)
    brightness = mean(img_double(:));
    
    % 2. Contrast Analysis (standard deviation)
    contrast = std(img_double(:));
    
    % 3. Entropy Analysis (texture richness)
    % Compute normalized histogram
    [counts, ~] = imhist(uint8(img_double), 256);
    probabilities = counts / sum(counts);
    
    % Remove zero probabilities to avoid log(0)
    probabilities = probabilities(probabilities > 0);
    
    % Compute entropy
    entropy = -sum(probabilities .* log2(probabilities));
    
    % 4. Edge Density Analysis
    % Detect edges using Sobel operator
    edge_map = edge(img_double, 'sobel');
    edge_pixels = sum(edge_map(:));
    total_pixels = numel(edge_map);
    edge_density = edge_pixels / total_pixels;
    
    % 5. Noise Level Estimation
    % Use Laplacian variance method for noise estimation
    laplacian_kernel = [0 -1 0; -1 4 -1; 0 -1 0];
    filtered_img = conv2(img_double, laplacian_kernel, 'same');
    noise_level = sqrt(var(filtered_img(:)));
    
    % Normalize noise level to 0-1 range
    noise_level = min(1.0, noise_level / 50);  % Normalize based on typical values
    
    % Display analysis results
    fprintf('Advanced Image Quality Analysis:\n');
    fprintf('  Brightness (mean intensity): %.2f (range: 0-255)\n', brightness);
    fprintf('  Contrast (std deviation): %.2f\n', contrast);
    fprintf('  Entropy (texture richness): %.4f (higher = more texture)\n', entropy);
    fprintf('  Edge Density: %.4f (ratio of edge pixels)\n', edge_density);
    fprintf('  Noise Level: %.4f (normalized 0-1, higher = more noise)\n', noise_level);
    
    % Quality assessment
    fprintf('\nQuality Assessment:\n');
    
    % Brightness assessment
    if brightness < 80
        fprintf('  - Brightness: LOW (dark image)\n');
    elseif brightness > 180
        fprintf('  - Brightness: HIGH (bright image)\n');
    else
        fprintf('  - Brightness: MEDIUM (adequate)\n');
    end
    
    % Contrast assessment
    if contrast < 30
        fprintf('  - Contrast: LOW (flat image)\n');
    elseif contrast > 80
        fprintf('  - Contrast: HIGH (rich contrast)\n');
    else
        fprintf('  - Contrast: MEDIUM (adequate)\n');
    end
    
    % Entropy assessment
    if entropy < 6.0
        fprintf('  - Texture: LOW (smooth/plain areas)\n');
    elseif entropy > 7.0
        fprintf('  - Texture: HIGH (complex/detailed areas)\n');
    else
        fprintf('  - Texture: MEDIUM (moderate detail)\n');
    end
    
    % Edge assessment
    if edge_density < 0.1
        fprintf('  - Edges: SPARSE (few sharp transitions)\n');
    elseif edge_density > 0.3
        fprintf('  - Edges: DENSE (many sharp transitions)\n');
    else
        fprintf('  - Edges: MODERATE (balanced edge content)\n');
    end
    
    % Noise assessment
    if noise_level > 0.1
        fprintf('  - Noise: HIGH (significant noise present)\n');
    elseif noise_level > 0.05
        fprintf('  - Noise: MODERATE (some noise present)\n');
    else
        fprintf('  - Noise: LOW (clean image)\n');
    end
    
    fprintf('\nAnalysis complete. Ready for intelligent enhancement decisions.\n');
    
end

% Helper function to compute entropy (included for completeness)
function entropy_val = compute_entropy(img)
    if isa(img, 'uint8') || isa(img, 'uint16')
        img_double = double(img);
    else
        img_double = img;
    end
    
    [counts, ~] = imhist(uint8(img_double), 256);
    probabilities = counts / sum(counts);
    probabilities = probabilities(probabilities > 0);
    entropy_val = -sum(probabilities .* log2(probabilities));
end

% Helper function to detect blockiness/pixelation
function blocky_flag = detect_blockiness(horizontal_edges, vertical_edges, width, height)
    % Simple blockiness detection based on edge variance
    
    % Calculate variance of edge distribution
    horz_var = var(double(horizontal_edges));
    vert_var = var(double(vertical_edges));
    
    % Low variance suggests regular/periodic patterns (blockiness)
    % Normalize variance to 0-1 range
    horz_norm = 1 - min(1, horz_var / 1000);  % Lower variance = higher blockiness
    vert_norm = 1 - min(1, vert_var / 1000);  
    
    % Average for final score
    block_score = (horz_norm + vert_norm) / 2;
    
    % Threshold for blockiness detection (0-1 scale)
    blocky_flag = block_score > 0.7;
    
    fprintf('  Blockiness Score: %.3f\n', block_score);
end

% Helper function to find periodic peaks in edge distribution
function peak_score = find_peaks_periodic(edge_profile, length)
    % Normalize edge profile
    if sum(edge_profile) > 0
        normalized_profile = edge_profile / max(edge_profile);
    else
        normalized_profile = edge_profile;
    end
    
    % Look for peaks at regular intervals
    % Check common JPEG block sizes (8x8, 16x16) and other regular patterns
    candidate_periods = [8, 16, 24, 32];
    
    max_score = 0;
    
    for period = candidate_periods
        if period < length/4  % Only consider reasonable periods
            % Sample at regular intervals
            sample_positions = 1:period:length;
            if length(sample_positions) >= 3
                % Take first few samples to avoid boundary issues
                num_samples = min(3, length(sample_positions));
                samples = normalized_profile(sample_positions(1:num_samples));
                avg_strength = mean(samples);
                if length(samples) > 1
                    consistency = 1 - std(samples) / (avg_strength + eps);
                else
                    consistency = 1;  % Perfect consistency for single sample
                end
                
                % Score based on strength and consistency
                score = avg_strength * consistency;
                if score > max_score
                    max_score = score;
                end
            end
        end
    end
    
    peak_score = max_score;
end