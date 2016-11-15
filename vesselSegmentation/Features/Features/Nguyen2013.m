
function [features, bestResponsesAngles] = Nguyen2013(I, mask, unary, options)
% Nguyen2013 Compute the Nguyen et al features
% I = Nguyen2013(I, mask, unary, options)
% OUTPUT: features: Nguyen et al features
% INPUT: I: grayscale image
%        mask: a binary mask representing the FOV
%        unary: a boolean flag indicating if the feature is unary or
%        pairwise
%        options: a struct containing the parameters to compute the feature
    
    % Set parameters
    if (~exist('options','var'))
        options.w = 15;
        step = 2;
    else
        step = options.step;
    end
        
    if (mod(options.w, 2)==0)
        options.w = options.w + 1;
    end
    if (mod(step, 2)==1)
        step = step - 1;
    end
    first = 1;

    % Get the green inverted channel
    I = 1 - im2double(I);
    mask = im2bw(double(mask));

    % Preallocate the Ls and the responses
    Ls = first:step:options.w;
    responses = zeros(size(I,1), size(I,2), length(Ls));
    bestResponsesAngles = zeros(size(I,1), size(I,2), length(Ls));
    
    % Compute the response for different Ls
    features = zeros(size(I,1), size(I,2), length(Ls)+1);
    for j = 1:numel(Ls)
       
       % Get the response
       [responses(:,:,j), bestResponsesAngles(:,:,j)] = get_lineresponse(I, 0:15:165, options.w, Ls(j)); 
       
       % Standardize it
       features(:,:,j) = standardize(responses(:,:,j), mask);
    
    end     
    
    % Get the standardize intensity
    features(:,:,length(Ls)+1) = standardize(I, mask);
    
    if (~unary)
        % Add it to the rest of the feature
       features = sum(features,3) / (size(features,3));
    end
    

end

