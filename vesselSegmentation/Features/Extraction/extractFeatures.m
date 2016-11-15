
function [features, dimensionality, numberOfPixels, masks, imgNames] = extractFeatures(imagesPath, masksPath, config, selectedFeatures, isUnary)
%
%
%
%

    % retrieve image names...
    imgNames = dir(imagesPath);
    imgNames = {imgNames.name};
    imgNames(strcmp(imgNames, '..')) = [];
    imgNames(strcmp(imgNames, '.')) = [];
    imgNames = removeFileNamesWithExtension(imgNames, 'mat');
    % ...and mask names
    mskNames = dir(masksPath);
    mskNames = {mskNames.name};
    mskNames(strcmp(mskNames, '..')) = [];
    mskNames(strcmp(mskNames, '.')) = [];
    % initialize number of pixels
    numberOfPixels = 0;
    
    % Remove features we will not include
    config.features.features(selectedFeatures==0) = [];
    config.features.featureParameters(selectedFeatures==0) = [];
    config.features.featureNames(selectedFeatures==0) = [];

    % Preallocate the cell array where the features will be stored
    features = cell(size(imgNames));
    % And where the masks will be stored
    masks = cell(size(imgNames));
    
    % for each image, verify if the feature file exist. if it is not there,
    % then we should compute it
    for i = 1 : length(imgNames)

        fprintf('Extracting features from %i/%i\n',i,length(imgNames));
        
        % open the mask
        mask = imread(strcat(masksPath, filesep, mskNames{i})) > 0;
        mask = mask(:,:,1);
        masks{i} = mask;

            
        features{i} = extractFeaturesFromSingleImage(imagesPath, imgNames{i}, mask, config, isUnary);
        
        % increment the number of pixels
        numberOfPixels = numberOfPixels + size(features{i}, 1);
            
    end
        
    % return the dimensionality of the feature vector
    dimensionality = size(features{1}, 2);

    % remove the extension from all the filenames
    for i = 1 : length(imgNames)
        filename = imgNames{i};
        imgNames{i} = filename(1:end-4);
    end
    
end