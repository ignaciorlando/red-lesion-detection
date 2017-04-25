function [I_out] = contrastEqualization(I, mask)

    I_out = uint8(zeros(size(I)));
    w = floor(3*(size(I,2))/30);
    
    for i = 1 : size(I,3)
        
        % fakepad current color band
        [I_extended, mask_extended] = fakepad(I(:,:,i), mask, 5, w);
        % apply gaussian filter
        G = imfilter(I_extended, fspecial('gaussian', [w, w], (size(I,1))/30));
        % rebuild image
        I_extended = 4 * double(I_extended) - 4 * double(G) + 128;
        % rebuild current color band
        I_current = zeros(size(I(:,:,i)));
        I_current(mask) = I_extended(mask_extended>0);
        % assign current band to the new image
        I_out(:,:,i) = uint8(I_current);
        
    end
    
end