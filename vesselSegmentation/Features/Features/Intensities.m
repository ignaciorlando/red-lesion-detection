
function I = Intensities(I, mask, unary, options)
% Intensities Compute the intensity feature
% I = Intensities(I, mask, unary, options)
% OUTPUT: I: image intensities
% INPUT: I: grayscale image
%        mask: a binary mask representing the FOV
%        unary: a boolean flag indicating if the feature is unary or
%        pairwise
%        options: a struct containing the parameters to compute the feature

    % Assign the sigmas and the thresholds
    if (~exist('options','var'))
        winsize = 35;
    else
        winsize = options.winsize;
    end
    % If the filter is not given in the options, the default filter is the
    % median
    if (~isfield(options, 'filter'))
        options.filter = 'median';
    end
    if (strcmp(options.filter, 'gaussian'))
        % Extend the borders of the mask
        mask2 = fakepad(double(mask), mask, 5, options.fakepad_extension);
        % Estimate the background
        background = roifilt2(fspecial('gaussian', [winsize winsize], (winsize-1)/3),I,mask2>0);
    else
        background = medfilt2(I, [winsize winsize]);
    end
    
    % Remove the background from the original image
    I = I - double(background);

end