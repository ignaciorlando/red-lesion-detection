
function [ candidates ] = getLesionCandidates(I, fov_mask, L0, step, L, K, px)

    % ---------------------------------------------------------------------
    % PREPARE DATA
    % ---------------------------------------------------------------------
    % create logical masks
    fov_mask = fov_mask(:,:,1) > 0;
    % if given image is in color, get only the green band
    if size(I,3)>1
        I = I(:,:,2);
    end
    % transform image to doubles
    I = im2double(I);
    % This is to adapt the size of the lesions to the parameter that we
    % give
    scales = L0:step:round(L/1425 * size(fov_mask,2));
    
    % preprocess the image
    [I] = walterKleinContrastEnhancement(I, fov_mask);
    
    % ---------------------------------------------------------------------
    % GET A SET OF INITIAL GUESSES
    % ---------------------------------------------------------------------
    initial_guesses = zeros(size(I,1), size(I,2), length(scales));
    for i = 1 : length(scales)
        [initial_guesses(:,:,i)] = getInitialGuessesOfLesions(I, fov_mask, scales(i), K);
    end
    candidates = max(initial_guesses, [], 3) > 0;
    candidates = bwareaopen(candidates, px);

end




