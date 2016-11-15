function result = convolution(img, filterkernel, imgfft)
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% CONVOLUTION: convolves IMG with FILTERKERNEL (by use of fft). If IMGFFT already contains
% the fft of IMG, this IMGFFT is used and less calculations are made.
% CONVOLUTION can be called with 2 or 3 parameters:
%
%   CONVOLUTION(IMG, FILTERKERNEL) convolves
%     IMG - the matrix to convolve with the kernel 
%     FILTERKERNEL - the filterkernel to convolve IMG with in the frequency domain
%
%   CONVOLUTION(IMG, FILTERKERNEL, IMGFFT) convolves
%     IMG - the matrix to convolve with the kernel 
%     FILTERKERNEL - the filterkernel to convolve IMG with in the frequency domain
%     IMGFFT - this value should contain the fft of IMG 
%              this reduces calculations if IMG remains the same over time

%   It is possible to speedup the process in case the imagesize is an exact power of 2.
%   Then the lines in the third codesection should be commented out and the lines in the fourth
%   code section should be decommented. This should also be done in the local function
%   'CREATEFFTIMAGE' in the file 'GABORFILTER'.

% check if there are only two parameters, if this is the case then set imgfft to -Inf 
% (meaning not yet calculated)
if (nargin == 2)
  imgfft = -Inf;
end

% store the sizes of the filterkernel and image
[fh, fw] = size(filterkernel); % size of the kernel is fh x fw
[imh,imw] = size(img); % size of the image is imh x imw

% the size of the convolution should be an even number
% Note: for more efficiency use max(fw, imw) instead of fw+imw (and idem for
% the height). Speedups are considerable (approximately a factor 2!). This results 
% in artefacts near the image borders though. 
% Remember to ALSO uncomment this in the local function 
% 'createfftimage' in the file 'gaborfilter.m'.
nh = (fh + imh) + mod(fh + imh, 2);
nw = (fw + imw) + mod(fw + imw, 2);
% nh = (max(fh,imh)) + mod(max(fh,imh), 2);
% nw = (max(fw,imw)) + mod(max(fw,imw), 2);

% calculate the size difference between the image & the convolution size
cix = fix((nw - imw)/2); 
ciy = fix((nh - imh)/2); 

% calculate the size difference between the filterkernel & the convolution size
cfx = ceil((nw - fw)/2);
cfy = ceil((nh - fh)/2);

% if imagefft does not contain the value -Inf it contains the 
% fft of img and it doesn't calculate it again.
if (imgfft == -Inf) 
  resultimg = padarray(img, [ciy cix], 'symmetric', 'both'); % symmetric padding
  imgfft = fft2(resultimg, nh, nw);
end

resultkernel = padarray(filterkernel, [cfy cfx], 'both'); % padding with zero's
filterkernelfft = fft2(resultkernel, nh, nw);

% convolution in frequency domain
convolResult = imgfft .* filterkernelfft;

% translate the result back to image domain and swap quadrants using fftshift
resultUnclipped = real(fftshift(ifft2(convolResult)));
 
% only the image in the original size should be returned
result = resultUnclipped(ciy+1:ciy+imh, cix+1:cix+imw);