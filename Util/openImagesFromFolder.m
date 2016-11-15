
function [images] = openImagesFromFolder(folder)

    % Get file names
    [allNames] = getImageFilenames(folder);
    % Get all the images in the directory and count the number of pixels
    images = cell(length(allNames), 1);
    for i = 1:length(allNames)
      currentfilename = strtrim(allNames{i});
      currentfilename = strrep(currentfilename, '''', '');
      currentImage = imread(strcat(folder, filesep, currentfilename));
      images{i} = currentImage; % Assign the image
    end

end