
config_downsampleSet;

for d = 1 : length(sourcePaths)

    % Path where the images are saved
    imagePath = sourcePaths{d};
    outputPath = outputPaths{d};

    % Retrieve the names of the files in the folder
    imageNames = getMultipleImagesFileNames(imagePath);
    
    % For each image
    for i = 1 : length(imageNames)   
        fprintf('%d/%d\n',i,length(imageNames));
        % Open image
        I = imread(strcat(imagePath, filesep, imageNames{i}));    
        % Resize the images
        if (are_labels)
            I = imresize(I, scale, 'nearest');
        else
            I = imresize(I, scale);
        end
        if length(unique(I(:)))==2
            I = I > 0;
        end
        % Save the image
        imwrite( I, strcat(outputPath, filesep, imageNames{i}));
    end
    
end