
function generate_red_lesion_ground_truth_annotations(ma_label_folder, hemorrhages_label_folder, red_lesion_folder, probability_threshold)

    % retrieve all the images in the ma_label_folder
    ma_label_confmap_labels = getMultipleImagesFileNames(ma_label_folder);
    % same for hemorrhages
    hemorrhages_label_confmap_labels = getMultipleImagesFileNames(hemorrhages_label_folder);
    
    % if the output folder does not exist, create it
    mkdir(red_lesion_folder);
    
    % output the red lesion ground truth as in Seoud et al., 2015
    for current_lbl_idx = 1 : length(ma_label_confmap_labels)
        
        % get current MA labelling
        current_ma_labelling = imread(fullfile(ma_label_folder, ma_label_confmap_labels{current_lbl_idx}));
        current_ma_labelling = (current_ma_labelling / 252) > 0.25;
        % get current HE labelling
        current_he_labelling = imread(fullfile(hemorrhages_label_folder, hemorrhages_label_confmap_labels{current_lbl_idx}));
        current_he_labelling = (current_he_labelling / 252) > 0.25;
        
        % initialize current red lesion labelling
        current_red_lesions_labelling = double(cat(3, current_ma_labelling, current_he_labelling));
        current_red_lesions_labelling = max((current_red_lesions_labelling), [], 3);
        imwrite(current_red_lesions_labelling, fullfile(red_lesion_folder, ma_label_confmap_labels{current_lbl_idx}));
        
    end
    
    % now, iterate for each ground truth labelling to output microaneurysms
    % and hemorrhages labels
    for current_lbl_idx = 1 : length(ma_label_confmap_labels)
        
        % get current MA labelling
        current_ma_labelling = imread(fullfile(ma_label_folder, ma_label_confmap_labels{current_lbl_idx}));
        current_ma_labelling = (current_ma_labelling / 252) >= probability_threshold;
        imwrite(current_ma_labelling, fullfile(ma_label_folder, ma_label_confmap_labels{current_lbl_idx}));
        
        % get current HE labelling
        current_he_labelling = imread(fullfile(hemorrhages_label_folder, hemorrhages_label_confmap_labels{current_lbl_idx}));
        current_he_labelling = (current_he_labelling / 252) >= probability_threshold;
        imwrite(current_he_labelling, fullfile(hemorrhages_label_folder, hemorrhages_label_confmap_labels{current_lbl_idx}));
        
    end
        


end


