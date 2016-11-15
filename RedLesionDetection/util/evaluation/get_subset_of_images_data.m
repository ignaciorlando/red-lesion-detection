
function [sub_features, sub_labels] = get_subset_of_images_data(subset_ids, all_features, all_labels)

    % initialize the output arrays
    sub_features = [];
    sub_labels = [];

    % for each id in the subset id
    for current_id = 1 : length(subset_ids)
        
        % retrieve indices equal to the current one
        current_image_ids = (all_image_ids==current_id);
        % retrieve all features corresponding to the current image id
        current_features = all_features(current_image_ids, :);
        % retrieve all labels corresponding to the current image id
        current_labels = all_labels(current_image_ids);
        
        % concatenate all data
        sub_features = cat(1, sub_features, current_features);
        sub_labels = cat(1, sub_labels, current_labels);
        
    end

end