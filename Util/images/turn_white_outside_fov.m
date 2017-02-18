
function I = turn_white_outside_fov(I, mask)

    % if the image is a uint8, then white is 255
    if isa(I,'uint8')
        white = 255;
    else
        white = 1;
    end
    
    % resize image
    if size(I,1) ~= size(mask,1)
        I = imresize(I, size(mask));
    end
    
    % turn mask into a logical matrix
    mask = mask > 0;
    % get the blank area
    outside_fov = imcomplement(mask);
    
    % for each of the color channels, turn outside the fov white
    for i = 1 : size(I,3)
        this_channel = I(:,:,i);
        this_channel(outside_fov) = white;
        I(:,:,i) = this_channel;
    end

end