function image = rescaleImage(image, mn, mx)
    if ~isempty(image)
        maximum = max(image(:));
        minimum = min(image(:));
        if (maximum - minimum) == 0
            image = ones(size(image)) * mx;
        else
            image = (((image-minimum)/(maximum-minimum) * (mx - mn)) + mn);
        end
    end
end