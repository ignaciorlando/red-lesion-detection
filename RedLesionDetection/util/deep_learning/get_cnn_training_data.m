
function [current_windows, current_labels, candidates_coordinates] = get_cnn_training_data(I, candidate, gt_labels, show_windows_in_images, mask)

    % retrieve a set of windows centered on each of the MA centers
    [current_windows, candidates_coordinates] = maWindowsExtraction(candidate, I, 32, show_windows_in_images, mask);

    % get the labels
    if ~isempty(gt_labels)
        [current_labels] = getMaLabels(gt_labels, candidates_coordinates);
    else
        current_labels = [];
    end
    
end