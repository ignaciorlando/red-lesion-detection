function [outputImage, segm2] = imageInpainting(I_in, segm)

    % ---------------------------------------------------------------------
    % PREPROCESS SEGMENTATIONS
    % ---------------------------------------------------------------------

    % get structures with more than 100 pixels
    segm = bwareaopen(segm, round(100/536 * size(segm,2)));
    % apply a closing to compensate error in the central reflex
    segm2 = imclose(segm, strel('disk',2,8));
    % dilate to improve inpainting
    segm = imdilate(segm2, strel('disk',2,8));

    % ---------------------------------------------------------------------
    % PREPROCESS IMAGES
    % ---------------------------------------------------------------------
    I = (zeros(size(segm,1), size(segm,2), size(I_in, 3)));
    if isa(I_in, 'uint8')
        I = uint8(I);
    end
    for i = 1 : size(I,3)
        I(:,:,i) = imresize(I_in(:,:,i), size(segm));
    end
    
    % ---------------------------------------------------------------------
    % INPAINTING
    % ---------------------------------------------------------------------
    outputImage = zeros(size(I));
    I = im2double(I);
    for i = 1 : size(I,3)
        outputImage(:,:,i) = regionfill(I(:,:,i), segm);
    end
    %outputImage = imresize(outputImage, size(I_in));

end