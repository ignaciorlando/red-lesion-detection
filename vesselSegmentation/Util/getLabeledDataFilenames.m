
function [images, labels, masks] = getLabeledDataFilenames(folder)

    imagesFolder = strcat(folder, filesep, 'images', filesep);
    masksFolder = strcat(folder, filesep, 'masks', filesep);
    labelsFolder = strcat(folder, filesep, 'labels', filesep);

    % Open images, masks and labels for the training set
    images = getMultipleImagesFileNames(imagesFolder);
    masks = getMultipleImagesFileNames(masksFolder);
    labels = getMultipleImagesFileNames(labelsFolder);

end
