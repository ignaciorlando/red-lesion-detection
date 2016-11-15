function simg = standardize(img,mask,wsize)

if (nargin == 2 || wsize == 0)
    simg = globalstandardize(img,mask);  
else
    img(mask == 0) = 0;
    img_mean = nlfilter(img,[wsize, wsize],@getmean);
    img_std = nlfilter(img,[wsize, wsize],@getstd);

    simg = (img - img_mean)./img_std;
    simg(img_std == 0) = 0;
    simg(mask == 0) = 0;
end

end

function simg = globalstandardize(img,mask)
usedpixels = double(img(mask==1));
m = mean(usedpixels);
s = std(usedpixels);

simg = zeros(size(img));
simg(mask == 1) = (usedpixels - m)/s;
end

function m = getmean(x)
usedx = x(x ~= 0);
m = mean(usedx);
end

function s = getstd(x)
usedx = x(x ~= 0);
s = std(usedx);
end