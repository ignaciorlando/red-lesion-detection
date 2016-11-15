function [result filterkernel] = gaborfilter(img, lambda, sigma, theta, phi, gamma, bandwidth)
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% GABORFILTER: calculates all the convolutions of the input image IMG with
% the Gabor-filterkernels for all combinations of orientations (which are 
% stored in the array THETA) and all phase-offsets (as stored in the array PHI) with the input image IMG. 
% The result is a 4-dimensional matrix of which the first two indices are the image-coordinates,
% the third index is the phaseoffset, the fourth index is the orientation.
% i.e. RESULT(:,:,phaseoffset(i),orientation(j)).
% A progressbar of the calculations is also shown.
%   GABORFILTER(IMG, LAMBDA, SIGMA, THETA, PHI, GAMMA, BANDWIDTH) calculates
%   all convolutions as described above, with the following parameters:
%     IMG - a matrix with values (an already read input image)
%     LAMBDA - preferred wavelength (wavelength of the cosine factor) of a Gabor function
%     SIGMA - standard deviation of Gaussian factor
%     THETA - list of all orientations
%     PHI   - list of all phase-offsets              
%     GAMMA - spatial aspect ratio (of the x- and y-axis of the Gaussian elipse) 
%     BANDWIDTH - spatial frequency bandwidth
%     To use the BANDWIDTH, one of the parameters SIGMA or LAMBDA must
%     contain the value 0. Otherwise BANDWIDTH is ignored.

% display a progressbar
%h = waitbar(0,'Calculating convolutions, please wait... (Step 1/7)');

% calculate the fft of the input image IMG to speedup processing
% the size of the filterkernel can be used in the creation of the fft-image to make 
% it larger with the size of the filterkernel in order to prevent boundary effects.
% This possibility is not used now, but one can switch it on in the local function
% CREATEFFTIMAGE (see below) and CONVOLUTION.M.
filterkernel = gaborkernel2d(lambda, sigma, theta(1), phi(1), gamma, bandwidth); % called only to determine the size of the filterkernel
fftimage = createFftImage(img, filterkernel); 

% initialise values
nrtheta = size(theta,2); % number of orientations 
nrphi = size(phi,2); % number of phaseoffsets

% calculate and store all convolutions
cnt1 = 1;
while (cnt1 <= nrtheta)
  cnt2 = 1;
%  waitbar(cnt2/(nrtheta*nrphi)); % update the progressbar
  while (cnt2 <= nrphi) % for each phi the convolution is calculated
    filterkernel = gaborkernel2d(lambda, sigma, theta(cnt1), phi(cnt2), gamma, bandwidth);
    result(:,:,cnt2,cnt1) = convolution(img, filterkernel, fftimage);
    cnt2 = cnt2 + 1;
%    waitbar((cnt2 + (cnt1-1)*nrphi)/(nrtheta*nrphi)); % update the progressbar
  end
  cnt1 = cnt1 + 1;
end
%waitbar(1);
%close(h);


% ---------------------------------------------------------------- %
% ---------------- Local function createFftImage ----------------- %
% ---------------------------------------------------------------- %
function result = createFftImage(img, filterkernel)
% VERSION 19/11/03
% CREATED BY: M.B. Wieling, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% CREATEFFTIMAGE: convolves IMG with FILTERKERNEL (by use of fft). The size of the convolution
%                 is of the size wich is also used in CONVOLUTION. This method is included
%                 because now the calculation of the FFT of the image (which is the same
%                 every time) has to be carried out only once).
%   CREATEFFTIMAGE(IMG, FILTERKERNEL) convolves
%     IMG - the matrix which should be convolved with the:
%     FILTERKERNEL - the filterkernel to convolve IMG with in the frequency domain

% initialize values
[fh, fw] = size(filterkernel); % size of the kernel is fh x fw
[imh,imw] = size(img); % size of the image is imh x imw

% the size of the convolution should be an even number
% Note: for more efficiency use max(fw, imw) instead of fw+imw (and idem for
% the height). Speedups are considerable (approximately a factor 2!). This results 
% in artefacts near the image borders though. 
% Remember to ALSO uncomment this in 'convolution.m'
nh = (fh + imh) + mod(fh + imh, 2);
nw = (fw + imw) + mod(fw + imw, 2);
% nh = (max(fh,imh)) + mod(max(fh,imh), 2);
% nw = (max(fw,imw)) + mod(max(fw,imw), 2);

% Calculate the size difference between the image & the convolution size
cix = fix((nw - imw)/2); 
ciy = fix((nh - imh)/2); 

% Calculate the size difference between the filterkernel & the convolution size
cfx = ceil((nw - fw)/2);
cfy = ceil((nh - fh)/2);

resultimg = padarray(img, [ciy cix], 'symmetric', 'both'); % symmetric padding
result = fft2(resultimg, nh, nw); % calculate the fft