
function [tophat] = getTopHatTransformation(I, l)

    % for each angle, compute a morphological closing
    angles = 0:15:179;
    closings = zeros(size(I,1), size(I,2), length(angles));
    for i = 1 : length(angles)
        closings(:,:,i) = imclose(I, strel('line', l, angles(i)));
    end

    % compute top hat and remove elements outside the mask and inside the
    % od
    tophat = (imcomplement(I - min(closings, [], 3)) - 1);

end