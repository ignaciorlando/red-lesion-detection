
function [pairwiseDeviations] = getPairwiseDeviations(pairwiseFeatures, pairwiseDimensionality)
% getPairwiseDeviations Obtain the pairwise deviations for the pairwise
% kernels.
% [pairwiseDeviations] = getPairwiseDeviations(pairwiseFeatures, pairwiseDimensionality)
% OUTPUT: pairwiseDeviations: pairwise deviations.
% INPUT: pairwiseFeatures: a cell array containing all the pairwise
%               features
%        pairwiseDimensionality: pairwise features dimensionality

    % Get the number of rows of the feature vector and preallocate a matrix
    dim1 = 0;
    for i = 1 : length(pairwiseFeatures)
        dim1 = dim1 + size(pairwiseFeatures{i}, 1);
    end;
    
    % Preallocate the pairwiseDeviations vector
    pairwiseDeviations = zeros(pairwiseDimensionality, 1);

    % For each pairwise feature
    for i = 1 : pairwiseDimensionality
        
        % For each image, assign features to their corresponding position
        % in X
        X = zeros(dim1, 1);
        pos = 1;
        for j = 1 : length(pairwiseFeatures)
            features = pairwiseFeatures{j}; % Get all features of the j-th image
            features = features(:,i); % Take only the i-th feature
            X(pos : pos + size(features,1) - 1, 1) = features(:); % Assign the feature
            pos = pos + size(features,1); % Update the first position
        end

        % Estimate the pairwise deviation
        N = 50; % Max number of samples taken from X
        pp = X; % get the pairwise feature
        medd = zeros(N,1); % a vector for each median
        for j = 1 : N
            if (length(pp) > 10000)
                [rndSamp, ind] = datasample(pp, 10000, 'Replace', false); % take a random sample without reposition
                pp(ind)=[]; % remove sampled points from the feature vector (sampling without replacement)
            else
                rndSamp = pp;
                pp = X;
            end
            medd(j) = abs((median(pdist(rndSamp)))); % estimate the median from the random sample
        end
        pairwiseDeviations(i) = median(medd);
        
    end
    pairwiseDeviations(pairwiseDeviations==0) = 0.000001;
    disp(mat2str(pairwiseDeviations));
    
end