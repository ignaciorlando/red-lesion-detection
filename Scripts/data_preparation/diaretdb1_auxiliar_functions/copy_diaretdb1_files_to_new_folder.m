
function copy_diaretdb1_files_to_new_folder(images_names, ...
                                            input_images_path, input_ma_labels_path, input_hemorrhages_path, ...
                                            output_images_path, output_ma_labels_path, output_hemorrhages_path)
% COPY_DIARETDB1_FILES_TO_NEW_FOLDER  Copy images, MA and HE labels to a new folder.
%       images_names: cell array of image names to be copied
%       input_images_path: input image path
%       input_ma_labels_path: input ma labels path
%       input_hemorrhages_path: input he labels path
%       output_images_path: output image path
%       output_ma_labels_path: output ma labels path
%       output_hemorrhages_path: output he labels path

    % create output folders
    mkdir(output_images_path);
    mkdir(output_ma_labels_path);
    mkdir(output_hemorrhages_path);

    % separate DIARETDB1 within training and test
    for i = 1 : length(images_names)
        % copy images
        copyfile(fullfile(input_images_path, images_names{i}), ...
                 fullfile(output_images_path, images_names{i}), 'f');
        % copy MA labels
        copyfile(fullfile(input_ma_labels_path, images_names{i}), ...
                 fullfile(output_ma_labels_path, images_names{i}), 'f');
        % copy HE labels
        copyfile(fullfile(input_hemorrhages_path, images_names{i}), ...
                 fullfile(output_hemorrhages_path, images_names{i}), 'f');
    end

end