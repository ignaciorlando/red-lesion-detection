
function copy_diaretdb1_files_to_new_folder(images_names, ...
                                            input_images_path, input_ma_labels_path, input_hemorrhages_path, ...
                                            output_images_path, output_ma_labels_path, output_hemorrhages_path)

    % create output folders
    % make the folders
    mkdir(output_images_path);
    mkdir(output_ma_labels_path);
    mkdir(output_hemorrhages_path);

    % separate DIARETDB1 within training and test
    for i = 1 : length(images_names)
        % copy images
        copyfile(fullfile(input_images_path, images_names{i}), ...
                 fullfile(output_images_path, images_names{i}), 'f');

        copyfile(fullfile(input_ma_labels_path, images_names{i}), ...
                 fullfile(output_ma_labels_path, images_names{i}), 'f');

        copyfile(fullfile(input_hemorrhages_path, images_names{i}), ...
                 fullfile(output_hemorrhages_path, images_names{i}), 'f');
    end

end