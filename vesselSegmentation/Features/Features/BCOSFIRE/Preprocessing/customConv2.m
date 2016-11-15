function result = customConv2( img, img_mask, kernel )
    L = size(kernel, 1);
    result = conv2(img, kernel, 'same');
    n = (L-1)/2 ;
    
    tmpImg = ones(L + size(img, 1) - 1, L + size(img, 2) - 1);
    tmpImg(n+1:n + size(img, 1), n+1:n + size(img, 2)) = img;
    tmpMask = zeros(L + size(img, 1) - 1, L + size(img, 2) - 1);
    tmpMask(n+1:n + size(img, 1), n+1:n + size(img, 2)) = img_mask;

    for n1 = n+1:n + size(img, 1)
        for n2 = n+1:n + size(img, 2)
            matchFOV = tmpMask(n1-n:n1+n, n2-n:n2+n);% .* (kernel > 0);

            if ~all(all(matchFOV)) && tmpMask(n1, n2) == 1
                matchFOVfilter = matchFOV .* (kernel > 0);
                if sum(matchFOVfilter(:)) > 0
                    m = tmpImg(n1-n:n1+n, n2-n:n2+n);
                    %out-of-FOV pixels substitution with in-of-FOV pixels
                    %grey level average
                    m = m .* matchFOV;
                    avg = sum(m(:)) / sum(matchFOV(:));
                    outFOV = ~matchFOV;% .* (kernel > 0);
                    m = m + (avg .* outFOV);
                    m = m .* kernel;
                    result(n1 - n, n2 - n) = sum(m(:));
                end
            end
        end
    end
end