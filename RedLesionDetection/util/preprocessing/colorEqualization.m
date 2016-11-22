
function [I_] = colorEqualization(I, mask)

    I_ = zeros(size(I));
    mask2 = mask > 0;
    mask = mask2;
    %mask2 = imerode(mask, strel('disk',40,8));
    I = im2double(I);
    
    % For each color band
    for i = 1 : size(I,3)
        
        % Retrieve the ith band
        Ia = double(I(:,:,i));
        
        % -----------------------------------------------------------------
        % 1) Illumination equalization
        % -----------------------------------------------------------------
        
        % Estimate the mean value of the color band
        mu = double(mean(Ia(mask)));
        % Estimate the background
        hM1 = roifilt2(fspecial('average',[40 40]), Ia, mask);
        % Illumination equalization
        Iie = Ia + mu - hM1;
        
        % -----------------------------------------------------------------
        % 2) Denoising
        % -----------------------------------------------------------------
        
        % Apply a mean filter
        Idn = imfilter(Iie, fspecial('average',3));
        
        % -----------------------------------------------------------------
        % 3) Adaptive contrast equalization
        % -----------------------------------------------------------------
        
        %Ice = Idn + imfilter(Iie, 1-fspecial('average',15)) ./ stdfilt(I(:,:,i), ones(15));
        Ice = adapthisteq(Idn);
        
        % -----------------------------------------------------------------
        % 4) Color normalization
        % -----------------------------------------------------------------

        mu = mean(Ice(mask));
        sigma = std(Ice(mask));

        low_extreme = mu-3*sigma;
        high_extreme = mu+3*sigma;
        
        if (low_extreme<0)
            low_extreme = 0;
        end
        if (high_extreme>1)
            high_extreme = 1;
        end
        I_(:,:,i) = imadjust(Ice, [low_extreme high_extreme], [0 1]) .* double(mask2);
        
    end
    

end