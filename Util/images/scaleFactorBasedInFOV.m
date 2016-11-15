
function [scale_factor] = scaleFactorBasedInFOV(mask, expectedFOVdiameter)

    mask2 = double(mask > 0);
    
    CC = bwconncomp(mask2);
    componentsLength = cellfun(@length, CC.PixelIdxList);
    [~, indexes] = sort(componentsLength, 'descend');
    mask = bwareaopen(mask,componentsLength(indexes(1))-1);

    % Identify coordinates of the empty area
    x_axis = double(sum(mask, 1) > 0);
    x_axis_shifted = circshift(x_axis, [0 1]);
    x_gradient = find(abs(x_axis - x_axis_shifted));
    
    % Estimate FOV diameter
    if (~isempty(x_gradient))
        FOV_diameter = x_gradient(2) - x_gradient(1) + 1;
    else
        FOV_diameter = size(mask, 2);
    end
    
    % The scaling factor will be the size of the 
    if (FOV_diameter > expectedFOVdiameter)
        scale_factor = expectedFOVdiameter / FOV_diameter;
    else
        scale_factor = FOV_diameter / expectedFOVdiameter;
    end

end