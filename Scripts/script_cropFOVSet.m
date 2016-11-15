

% Retrieve the mask names
maskNames = getMultipleImagesFileNames(maskPaths);

% For each source path
for d = 1 : length(sourcePaths)
    
    % Path where the images are saved
    imagePath = sourcePaths{d};
    outputPath = outputPaths{d};

    disp(imagePath);
    
    % Retrieve the names of the files in the folder
    imageNames = getMultipleImagesFileNames(imagePath);

    % For each image
    for i = 1 : length(imageNames)   
        
        % Open image
        I = imread(fullfile(imagePath, imageNames{i}));    
        % Open mask
        mask = imread(fullfile(maskPaths, maskNames{i})) > 0;
        % Crop the image
        [ I, ~ ] = cropFOV( I, mask );
        % If the image is binary, write a logical
        if (length(unique(I(:)))==2)
            I = I > 0;
        end
        % Save the image
        % retrieve image name and extension
        [~, current_image_name, extension] = fileparts(imageNames{i}) ;
        if (strcmp(extension,'.jpg') || strcmp(extension,'.jpeg'))
            extension = '.png';
        end
        imwrite( I, fullfile(outputPath, filesep, strcat(current_image_name, extension)));
    end
    
end

% Save the masks
for i = 1 : length(maskNames)
    % Open mask
    mask = imread(fullfile(maskPaths, maskNames{i})) > 0;
    % Save the mask cropped
    [ mask, ~ ] = cropFOV( mask, mask );
    % Save the mask
    imwrite( mask>0, fullfile(maskPaths, maskNames{i}));
end