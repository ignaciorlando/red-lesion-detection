function [output sigma] = getDoG(img,sigma, onoff, sigmaRatio, width, threshold)
% create Difference of Gaussian Kernel

%sz = size(img) + width + width;    
sz = ceil(sigma*3) * 2 + 1;

g1 = fspecial('gaussian',sz,sigma);    
g2 = fspecial('gaussian',sz,sigma*sigmaRatio);

if onoff == 1
    G = g2 - g1;  
else
    G = g1 - g2;
end

img = padarray(img,[width width],'both','symmetric');

% compute DoG
%output = fftshift(ifft2(fft2(G,sz(1),sz(2)) .* fft2(resultimg)));
output = conv2(img, G, 'same');

if nargin == 6
    %output(output < threshold) = 0;
    output(find(output < threshold)) = 0;
end