
function [ candidates ] = getLesionCandidates(I, fov_mask, scales, K, px)

    % ---------------------------------------------------------------------
    % PREPARE DATA
    % ---------------------------------------------------------------------
    % create logical masks
    fov_mask = fov_mask > 0;
    % if given image is in color, get only the green band
    if size(I,3)>1
        I = I(:,:,2);
    end
    % transform image to doubles
    I = im2double(I);
    % check if scales variable exists
    if (exist('scales', 'var')==0)
        scales = [9, 12, 15, 17, 19, 21];
    end
    % preprocess the image
    [I] = walterKleinContrastEnhancement(I, fov_mask);
    
    % ---------------------------------------------------------------------
    % GET A SET OF INITIAL GUESSES
    % ---------------------------------------------------------------------
    initial_guesses = zeros(size(I,1), size(I,2), length(scales));
    parfor i = 1 : length(scales)
        [initial_guesses(:,:,i)] = getInitialGuessesOfLesions(I, fov_mask, scales(i), K);
    end
    candidates = max(initial_guesses, [], 3) > 0;
    candidates = bwareaopen(candidates, px);

end




