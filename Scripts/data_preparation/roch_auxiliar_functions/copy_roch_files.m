
function copy_roch_files(file_names, input_dir, output_dir)

    % copy all the images on the training set
    for i = 1 : length(file_names)
        % retrieve image filename and extension
        [~, filename, extension] = fileparts(file_names{i});
        % if the extension is jpg, then replace it by .png
        if strcmp(extension, '.jpg') || strcmp(extension, '.jpeg') || strcmp(extension, '.JPG') || strcmp(extension, '.JPEG')
            extension = '.png';
        end
        % copy file to the new folder
        copyfile(fullfile(input_dir, file_names{i}), ...
                 fullfile(output_dir, strcat(filename, extension)));
    end

end