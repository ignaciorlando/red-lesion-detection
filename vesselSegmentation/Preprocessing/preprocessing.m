
function [I_extended, mask_extended] = preprocessing(I, mask, options)
% preprocessing Preprocess the given image
% I = preprocessing(I, mask, options)
% OUTPUT: I: image preprocessed
% INPUT: I: image (it can be a RGB image)
%        mask: a binary mask indicating the FOV
%        options: a configuration structure containing the options

    if (~isfield(options, 'preprocess') || (isfield(options, 'preprocess') && options.preprocess))
        
        % get only the green band of the original color image
        if (size(I,3)>1)
            I = (I(:,:,2));
        end
        
        if strcmp(options.enhancement,'clahe')
            I = adapthisteq(I);
        end
        
        % extend the borders using the fakepad function
        [I_extended, mask_extended] = fakepad(I, mask, options.erosion, options.fakepad_extension);
               
    end
    
end