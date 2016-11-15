
function [images] = resizeImages(images, scale)

    for i = 1 : length(images)
        images{i} = imresize(images{i}, scale);
    end

end