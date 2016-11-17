
% SCRIPT_MEASURE_VESSEL_CALIBRE_MANUALLY
% -------------------------------------------------------------------------
% This code is used for measuring vessel calibre manually. Please, edit
% first config_measure_vessel_calibre_manually to assign the data set to
% measure.
% -------------------------------------------------------------------------

config_measure_vessel_calibre_manually;

% Retrieve the names of the images
root = fullfile(root, dataset_name, 'images');
imgNames = getMultipleImagesFileNames(root);

% Initialize an array of calibers
calibers = zeros(numImages, numProf);

% For each of the images in the list
for j = 1 : numImages

    disp(['Measuring calibers of image ', num2str(j)]);

    % Read the image
    I = imread(fullfile(root, imgNames{j}));
    imshow(I);
    
    % Compute the original coordinate
    origCoord = floor(size(I,1)/4);
    initialGuess = [origCoord, origCoord, size(I,1)-2*origCoord, size(I,1)-2*origCoord];
    h = imrect(gca, initialGuess);
    setFixedAspectRatioMode(h, 1);
    position = wait(h);
    % Crop the rectangle
    I = imcrop(I,position);
    
    % And now, we will use just that rectangle
    for i = 1 : numProf
        h = figure;
        imshow(I);
        set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
        profile = improfile;
        close all
        % Take the length of the profile as the calibre of the vessel
        calibers(j,i) = size(profile, 1);
    end

end

% The downsample value is
downsample_value = 8.73 / mean(mean(calibers, 2));