
function [R, bestResponse] = get_lineresponse(I, angles, W, L)

    % img: extended inverted gc
    % W: window size, L: line length
    % R: line detector response

    % Compute the average
    avgresponse = imfilter(I, fspecial('average', W), 'replicate');

    % Compute the responses
    imglinestrength = zeros(size(I,1), size(I,2), length(angles));
    
    for i = 1 : length(angles)
  
        linemask = get_linemask(angles(i), L);
        linemask = linemask / sum(linemask(:));
  
        imglinestrength(:,:,i) = imfilter(I, linemask) - avgresponse;    
           
    end
    
    [R, ang] = max(imglinestrength, [], 3); 
    bestResponse = angles(ang);

end


