
% SCRIPT_CROPFOVSET
% -------------------------------------------------------------------------
% This script is used to crop images around the FOV. This is useful to
% reduce the computational time. It required to initialize 3 variables:
%   sourcePaths: array list of paths where the data to be cropped is saved
%   outputPaths: array list of paths where the cropped data will be saved
%   maskPaths: path where the masks are saved.
% -------------------------------------------------------------------------

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
        [ I, mask ] = cropFOV( I, mask );
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
        if length(unique(I(:)))==2
            imwrite( I>0, fullfile(outputPath, filesep, strcat(current_image_name, extension)));
        else
            imwrite( uint8(I), fullfile(outputPath, filesep, strcat(current_image_name, extension)));
        end
    end
    
end
