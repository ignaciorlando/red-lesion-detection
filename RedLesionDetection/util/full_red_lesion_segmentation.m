
function [red_lesion_segmentation, score_map] = full_red_lesion_segmentation(I, mask, scales, K, px, cnn_for_feature_extraction, vessel_segmentation, detector)

    % if the image is bigger than images in MESSIDOR, it would be nice to
    % downscale it
    if size(I,2) > 1400
        downscale_factor = 1400 / size(I,2);
        I = imresize(I, downscale_factor, 'nearest');
        mask = imresize(mask, downscale_factor, 'nearest');
    else
        downscale_factor = 1;
    end

    % generate candidates
    red_lesion_candidates = getLesionCandidates(I, mask>0, scales, K, px);

    % extract CNN features
    % get CNN training data
    [current_windows, ~, current_candidates_coordinates] = get_cnn_training_data(I, red_lesion_candidates, [], false, mask);
    % remove training data mean to all the images
    current_windows = bsxfun(@minus, single(current_windows), cnn_for_feature_extraction.net.meta.trainOpts.dataMean);
    % retrieve features
    res = vl_simplenn(cnn_for_feature_extraction.net, current_windows) ;
    cnn_features = squeeze(gather(res(end).x))';

    % extract hand crafted features
    [hand_crafted_features, ~] = hand_crafted_features_extraction(red_lesion_candidates, I, vessel_segmentation, mask);

    % segment red lesions
    [red_lesion_segmentation, score_map, ~] = segmentRedLesions(detector, I, double(cat(2, cnn_features, hand_crafted_features)), current_candidates_coordinates);
    
    % resize score map and red lesion segmentation according to the
    % downscale factor
    if downscale_factor ~= 1
        red_lesion_segmentation = imresize(red_lesion_segmentation>0, size(I(:,:,1)), 'nearest');
        score_map = imresize(score_map, size(I(:,:,1)), 'nearest');
    end

end