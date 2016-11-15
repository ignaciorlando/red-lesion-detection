
function [zanan] = Zana2001(I, mask, unary, options)
% Zana2001 Compute the Zana and Klein feature
% I = Zana2001(I, mask, unary, options)
% OUTPUT: features: Zana and Klein features
% INPUT: I: grayscale image
%        mask: a binary mask representing the FOV
%        unary: a boolean flag indicating if the feature is unary or
%        pairwise
%        options: a struct containing the parameters to compute the feature

    % Preprocess the image
    %I = Intensities(I, mask, unary, options.Intensities);

    % Set parameters
    if (~exist('options','var'))
        l = 9;
    else
        l = options.l;
    end
    
    angles = 0:15:179;
    
    % get the complement of the input image
    I = imcomplement(I);

    % 1) Opening to remove noise
    opened = zeros(size(I,1), size(I,2), length(angles));
    for i = 1 : length(angles)
        opened(:,:,i) = double(imopen(I,strel('line', l, angles(i))));
    end
    maxopened = max(opened,[],3);
    
    % 2) Sum of top-hats for linear parts recognition
    Ssum = zeros(size(I,1), size(I,2));
    for i = 1 : length(angles)
        Ssum = Ssum + (double(imtophat(maxopened, strel('line', l, angles(i)))));
    end
    
    % 3) Curvature computation
    Slap = imfilter(Ssum, fspecial('log', [7 7], 7/4));
    
    % 4) Final filtering
    % first, the opening
    opened = zeros(size(I,1), size(I,2), length(angles));
    for i = 1 : length(angles)
        opened(:,:,i) = double(imopen(Slap,strel('line', l, angles(i))));
    end
    s1 = max(opened,[],3);
    
    % second, the closing
    closed = zeros(size(I,1), size(I,2), length(angles));
    for i = 1 : length(angles)
        closed(:,:,i) = double(imclose(s1,strel('line', l, angles(i))));
    end
    s2 = min(closed,[],3);
    
    % finally, the opening
    opened = zeros(size(I,1), size(I,2), length(angles));
    for i = 1 : length(angles)
        opened(:,:,i) = double(imopen(s2,strel('line', l, angles(i))));
    end
    zana = max(opened,[],3);  
    
    % DEPENDING ON THE TYPE OF FEATURE
    if (unary)
        % OUR MODIFICATION:
        % We split the feature in two, by taking the positive
        % and the negative part separated in case the feature is unary
        zanan = zeros(size(I,1), size(I,2), 2);
        z1 = zana;
        z1(z1<0) = 0;
        z2 = zana;
        z2(z2>0) = 0;
        zanan(:,:,1) = z1;
        zanan(:,:,2) = z2;
    else
        zanan = zana;
    end

    
end