
function [ma_features, candidates_pxs] = hand_crafted_features_extraction(red_lesion_candidates, I, segm, mask)

    % -------------------------------------------------------
    % PREPARE DATA
    % -------------------------------------------------------   
    % Generate logical matrices
    red_lesion_candidates = red_lesion_candidates > 0;
    segm = segm(:,:,1) > 0;
    % Transform image to double
    I = im2double(I);
    if (size(I,1) ~= size(segm,1))
        segm = imresize(segm, [size(I,1) size(I,2)], 'nearest');
    end
    % Get ma candidates
    conn = bwconncomp(red_lesion_candidates);
    
    % -------------------------------------------------------
    % PREPARE IMAGE FOR FEATURE EXTRACTION
    % -------------------------------------------------------
    % Get red, green and blue channels
    red = I(:,:,1);
    green = I(:,:,2);
    blue = I(:,:,3);
    % CLAHE and get red, green and blue channels
    red_c = adapthisteq(red);
    green_c = adapthisteq(green);
    blue_c = adapthisteq(blue);
    % Get statistics from connected components
    stats = regionprops(red_lesion_candidates, 'Area', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity');
    % Generate I_bg
    w_size = round(25/536 * size(mask,2));
    I_bg = im2double(medfilt2(uint8(green*255), [w_size w_size]));
    I_sc = green - I_bg;
    % Generate I_match
    I_lesion = imageInpainting(I_sc, segm>0);
    I_match = imgaussfilt(I_lesion - imfilter(I_lesion, fspecial('average',round(11/536 * size(mask,2)))), 1);
    % I_walter
    [walter] = walterKleinContrastEnhancement(green, mask);
    % I_walter + CLAHE
    walter_c = adapthisteq(walter);
    % Generate equalized image
    I_eq = im2double(contrastEqualization(uint8(I*255), mask));
    red_eq = I_eq(:,:,1);
    green_eq = I_eq(:,:,2);
    blue_eq = I_eq(:,:,3);
    % Compute the top hat transformation
    lengths = 5:2:15;
    I_tophat = zeros(size(I,1), size(I,2), length(lengths));
    for i = 1 : length(lengths)
        I_tophat(:,:,i) = getTopHatTransformation(walter,lengths(i));
    end
    I_tophat = max(I_tophat, [], 3);
    
    % Initialize feature vector
    ma_features = zeros(conn.NumObjects, 62);
    
    % begin feature extraction per each candidate
    for i = 1 : conn.NumObjects
        
        % retrieve pixels
        px = conn.PixelIdxList{i};
        % pixel mask
        px_mask = false(size(segm));
        px_mask(px) = true;
        % retrieve perimeter pixels
        px_perimeter = regionprops(bwperim(px_mask, 8), 'PixelList');
        % retrieve surrounding area
        px_surrounding = bwconncomp(imdilate(px_mask, strel('disk',6,8)), 8);
        px_surrounding = px_surrounding.PixelIdxList{1};
        
        % -----------------------------------------------------------------
        % INTENSITY STATISTICS
        % -----------------------------------------------------------------
        index = 1;
        % Mean red intensity
        ma_features(i, index) = mean(red(px)); index = index+1;
        % Mean green intensity
        ma_features(i, index) = mean(green(px)); index = index+1; 
        % Mean blue intensity
        ma_features(i, index) = mean(blue(px)); index = index+1; 
        % Mean walter intensity
        ma_features(i, index) = mean(walter(px)); index = index+1; 
        % Mean red intensity from CLAHE image
        ma_features(i, index) = mean(red_c(px)); index = index+1; 
        % Mean green intensity from CLAHE image
        ma_features(i, index) = mean(green_c(px)); index = index+1; 
        % Mean blue intensity from CLAHE image
        ma_features(i, index) = mean(blue_c(px)); index = index+1; 
        % Mean walter intensity from CLAHE image
        ma_features(i, index) = mean(walter_c(px)); index = index+1; 
        % Mean red intensity from color equalized image
        ma_features(i, index) = mean(red_eq(px)); index = index+1; 
        % Mean green intensity from color equalized image
        ma_features(i, index) = mean(green_eq(px)); index = index+1; 
        % Mean blue intensity from color equalized image
        ma_features(i, index) = mean(blue_eq(px)); index = index+1; 
        % Mean intensity from I_sc
        ma_features(i, index) = mean(I_sc(px)); index = index+1; 
        % 12 FEATURES SO FAR
        
        % Total red intensity
        ma_features(i, index) = sum(red(px)); index = index+1; 
        % Total green intensity
        ma_features(i, index) = sum(green(px)); index = index+1; 
        % Total blue intensity
        ma_features(i, index) = sum(blue(px)); index = index+1; 
        % Total walter intensity
        ma_features(i, index) = sum(walter(px)); index = index+1; 
        % Total red intensity from CLAHE image
        ma_features(i, index) = sum(red_c(px)); index = index+1; 
        % Total green intensity from CLAHE image
        ma_features(i, index) = sum(green_c(px)); index = index+1; 
        % Total blue intensity from CLAHE image
        ma_features(i, index) = sum(blue_c(px)); index = index+1; 
        % Total walter intensity from CLAHE image
        ma_features(i, index) = sum(walter_c(px)); index = index+1; 
        % Total red intensity from color equalized image
        ma_features(i, index) = sum(red_eq(px)); index = index+1;
        % Total green intensity from color equalized image
        ma_features(i, index) = sum(green_eq(px)); index = index+1; 
        % Total blue intensity from color equalized image
        ma_features(i, index) = sum(blue_eq(px)); index = index+1; 
        % Total intensity from I_sc
        ma_features(i, index) = sum(I_sc(px)); index = index+1;    
        % 12 FEATURES MORE (24 FEATURES SO FAR) 
        
        % Std red intensity
        ma_features(i, index) = std(red(px)); index = index+1; 
        % Std green intensity
        ma_features(i, index) = std(green(px)); index = index+1; 
        % Std blue intensity
        ma_features(i, index) = std(blue(px)); index = index+1; 
        % Std walter intensity
        ma_features(i, index) = std(walter(px)); index = index+1; 
        % Std red intensity from CLAHE image
        ma_features(i, index) = std(red_c(px)); index = index+1; 
        % Std green intensity from CLAHE image
        ma_features(i, index) = std(green_c(px)); index = index+1; 
        % Std blue intensity from CLAHE image
        ma_features(i, index) = std(blue_c(px)); index = index+1; 
        % Std walter intensity from CLAHE image
        ma_features(i, index) = std(walter_c(px)); index = index+1; 
        % Std red intensity from color equalized image
        ma_features(i, index) = std(red_eq(px)); index = index+1; 
        % Std green intensity from color equalized image
        ma_features(i, index) = std(green_eq(px)); index = index+1; 
        % Std blue intensity from color equalized image
        ma_features(i, index) = std(blue_eq(px)); index = index+1;    
        % Std intensity from I_sc
        ma_features(i, index) = std(I_sc(px)); index = index+1;           
        % 12 FEATURES MORE (36 FEATURES SO FAR)
        
        % Contrast red intensity
        ma_features(i, index) = mean(red(px)) - mean(red(px_surrounding)); index = index+1;
        % Contrast green intensity
        ma_features(i, index) = mean(green(px)) - mean(green(px_surrounding)); index = index+1; 
        % Contrast blue intensity
        ma_features(i, index) = mean(blue(px)) - mean(blue(px_surrounding)); index = index+1; 
        % Contrast walter intensity
        ma_features(i, index) = mean(walter(px)) - mean(walter(px_surrounding)); index = index+1; 
        % Contrast red intensity from CLAHE image
        ma_features(i, index) = mean(red_c(px)) - mean(red_c(px_surrounding)); index = index+1; 
        % Contrast green intensity from CLAHE image
        ma_features(i, index) = mean(green_c(px)) - mean(green_c(px_surrounding)); index = index+1; 
        % Contrast blue intensity from CLAHE image
        ma_features(i, index) = mean(blue_c(px)) - mean(blue_c(px_surrounding)); index = index+1; 
        % Contrast walter intensity from CLAHE image
        ma_features(i, index) = mean(walter_c(px)) - mean(walter_c(px_surrounding)); index = index+1; 
        % Contrast red intensity from color equalized image
        ma_features(i, index) = mean(red_eq(px)) - mean(red_eq(px_surrounding)); index = index+1; 
        % Contrast green intensity from color equalized image
        ma_features(i, index) = mean(green_eq(px)) - mean(green_eq(px_surrounding)); index = index+1; 
        % Contrast blue intensity from color equalized image
        ma_features(i, index) = mean(blue_eq(px)) - mean(blue_eq(px_surrounding)); index = index+1; 
        % Contrast intensity from I_sc
        ma_features(i, index) = mean(I_sc(px)) - mean(I_sc(px_surrounding)); index = index+1; 
        % 12 FEATURES MORE (48 FEATURES SO FAR)

        background_deviation = std(I_bg(px));
        if (background_deviation==0)
            background_deviation = 1;
        end        
        % Normalized total intensity in I_green
        ma_features(i, index) = (sum(green(px)) - mean(I_bg(px))) / background_deviation; index = index+1; 
        % Normalized total intensity in I_sc
        ma_features(i, index) = (sum(I_sc(px)) - mean(I_bg(px))) / background_deviation; index = index+1; 
        % Normalized total intensity in walter
        ma_features(i, index) = (sum(walter(px)) - mean(I_bg(px))) / background_deviation; index = index+1; 
        % 3 FEATURES MORE (51 FEATURES SO FAR)
        
        % Normalized average intensity in walter
        ma_features(i, index) = (mean(walter(px)) - mean(I_bg(px))) / background_deviation; index = index+1; 
        % 1 FEATURE MORE (52 FEATURES SO FAR)
        
        % I_darkest in I_match
        ma_features(i, index) = min(I_match(px)); index = index+1; 
        % Mean intensity in the candidate region on I_tophat
        ma_features(i, index) = mean(I_tophat(px)); index = index + 1;
        % 2 FEATURES MORE (54 FEATURES SO FAR)
        
%         % Average and std Gaussian filter response for different sigmas
%         sigmas = [1 2 4 8];
%         for s = 1 : length(sigmas)
%             I_gaussian = imgaussfilt(green,sigmas(s)); 
%             ma_features(i, index) = mean(I_gaussian(px));  index = index+1;
%             ma_features(i, index) = std(I_gaussian(px));  index = index+1;
%         end
        
        % -----------------------------------------------------------------
        % SHAPE STATISTICS
        % -----------------------------------------------------------------
        
        % Area
        ma_features(i, index) = stats(i).Area;  index = index+1;
        % Perimeters
        ma_features(i, index) = stats(i).Perimeter;  index = index+1;
        % Aspect ratio
        ma_features(i, index) = stats(i).MajorAxisLength / stats(i).MinorAxisLength;  index = index+1;
        % Circularity
        perimeter = stats(i).Perimeter;
        if (perimeter==0)
            perimeter=1;
        end
        ma_features(i, index) = (4*pi*stats(i).Area) / (perimeter)^2;   index = index+1;
        % Compactness
        if (stats(i).Perimeter==0)
            v = 0;
        else
            di = px_perimeter(1).PixelList;
            d = repmat(mean(px_perimeter(1).PixelList), [size(di,1), 1]);
            v = sqrt(sum(sum((di - d) .^ 2,2))) / stats(i).Perimeter;
        end
        ma_features(i, index) = v;  index = index+1;
        % Major axis length
        ma_features(i, index) = stats(i).MajorAxisLength;  index = index+1;
        % Minor axis length
        ma_features(i, index) = stats(i).MinorAxisLength;
        % Eccentricity
        ma_features(i, index) = stats(i).Eccentricity;
        % 8 FEATURES MORE (62 FEATURES SO FAR)
        
    end
    
    candidates_pxs = conn.PixelIdxList';

end