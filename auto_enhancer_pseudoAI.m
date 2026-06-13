function enhanced_img = auto_enhancer_pseudoAI(image_path, mode)

clc;

% ================= VALIDATION =================
if nargin < 2
    error('Usage: auto_enhancer_pseudoAI(image_path, mode)');
end

if ~exist(image_path, 'file')
    error('Image not found: %s', image_path);
end

if ~strcmpi(mode,'safe') && ~strcmpi(mode,'boost')
    error('Mode must be SAFE or BOOST');
end

fprintf('\n========== AI IMAGE ENHANCER ==========\n');
fprintf('Mode: %s\n\n', upper(mode));

% ================= READ IMAGE =================
original_img = imread(image_path);
orig_double = im2double(original_img);

[h,w,c] = size(original_img);
fprintf('Image Size: %dx%dx%d\n\n', h,w,c);

% ================= GRAYSCALE =================
if c==3
    gray = rgb2gray(orig_double);
else
    gray = orig_double;
end

% ================= DEFECT ANALYSIS =================
lap = del2(gray);
lap_var = var(lap(:));

low_res = min(h,w) < 400;
low_detail = lap_var < 0.001;

smooth = imgaussfilt(gray,1);
noise = std(abs(gray(:)-smooth(:))) > 0.05;

use_AI = low_res || low_detail || noise;

fprintf('--- AI DECISION ---\n');
fprintf('Low Res: %d | Blur: %d | Noise: %d\n',low_res,low_detail,noise);

if use_AI
    fprintf('➡ AI TRIGGERED\n\n');
else
    fprintf('➡ Classical Only\n\n');
end

% ================= ENHANCEMENT =================
if strcmpi(mode,'boost') && use_AI
    
    fprintf('Running RealESRGAN...\n');

    imwrite(original_img,'temp_in.png');

    system('.\realesrgan-ncnn-vulkan.exe -i temp_in.png -o temp_out.png -n realesrgan-x4plus');

    if exist('temp_out.png','file')
        enhanced = im2double(imread('temp_out.png'));              
        delete('temp_out.png');
    else
        warning('AI failed → fallback');
        enhanced = orig_double;
    end
    
    delete('temp_in.png');

    % Mild polish
    enhanced = imgaussfilt(enhanced,0.4);
    enhanced = imsharpen(enhanced,'Radius',0.7,'Amount',0.4);

else
    fprintf('Running Classical Enhancement...\n');

    enhanced = imadjust(gray,stretchlim(gray),[]);
    enhanced = histeq(enhanced);
    enhanced = medfilt2(enhanced,[5 5]);
    enhanced = imsharpen(enhanced,'Radius',1,'Amount',0.5);
end

% ================= RESIZE (IMPORTANT) =================
if size(enhanced,1) ~= h || size(enhanced,2) ~= w
    enhanced_resized = imresize(enhanced,[h w]);
else
    enhanced_resized = enhanced;
end

% ================= GRAYSCALE SAFE =================
if size(original_img,3)==3
    orig_gray = rgb2gray(im2double(original_img));
else
    orig_gray = im2double(original_img);
end

if size(enhanced_resized,3)==3
    enh_gray = rgb2gray(enhanced_resized);
else
    enh_gray = enhanced_resized;
end

% ================= HEATMAP =================
diff_map = abs(enh_gray - orig_gray);

% ================= ZOOM =================
crop_h = round(h*0.25);
crop_w = round(w*0.25);

x = round(w/2 - crop_w/2);
y = round(h/2 - crop_h/2);

zoom_orig = orig_gray(y:y+crop_h-1, x:x+crop_w-1);
zoom_enh  = enh_gray(y:y+crop_h-1, x:x+crop_w-1);
zoom_diff = abs(zoom_enh - zoom_orig);

% ================= OUTPUT =================
enhanced_img = im2uint8(enhanced_resized);

% ================= DISPLAY =================
figure('Color',[0.1 0.1 0.1]);

subplot(2,3,1); imshow(original_img); title('Original','Color','w');
subplot(2,3,2); imshow(enhanced_img); title('Enhanced','Color','w');
subplot(2,3,3); imshow(diff_map,[]); title('Heatmap','Color','w');

subplot(2,3,4); imshow(zoom_orig,[]); title('Zoom Original','Color','w');
subplot(2,3,5); imshow(zoom_enh,[]); title('Zoom Enhanced','Color','w');
subplot(2,3,6); imshow(zoom_diff,[]); title('Zoom Heatmap','Color','w');

fprintf('\n✅ DONE — Output Displayed Successfully\n');

end