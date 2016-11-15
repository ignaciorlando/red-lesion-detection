% Open multiple files from a given directory
function [images, allNames] = openMultipleImages(directory)
    % Get all file names
    allNames = getMultipleImagesFileNames(directory);
    % Get all the images in the directory and count the number of pixels
    images = cell(length(allNames), 1);
    for i = 1:length(allNames)
      currentfilename = strtrim(allNames{i});
      currentfilename = strrep(currentfilename, '''', '');
      currentImage = imread(strcat(directory, filesep, currentfilename));
      images{i} = currentImage; % Assign the image
    end
end