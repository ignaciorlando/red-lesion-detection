function [img, theta, sigma] = readandinit (img, theta, nors, sigma, lambda, bandwidth)
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% READANDINIT: fills the initial values (the matrix of the read image: IMG, 
%              a list with all orientations: THETA
%              the standard deviation of the gaussian factor: SIGMA)
%   READANDINIT(IMG, THETA, NORS, SIGMA, LAMBDA, BANDWIDTH) with the
%   following parameters:
%     IMG - name of the image as a string (e.g. 'lena.jpg')
%     THETA - list of one or more orientations, if only one orienation
%             (the start-orientation) is entered, NORS is used to calculate the entire list
%             of orientations (2*pi is divided by NORS and added
%             sequentially to the previous value in the list of THETA), if 
%             multiple values are entered, NORS is ignored
%     NORS - number of orientations (see also THETA)
%     SIGMA - standard deviation of Gaussian factor
%     LAMBDA - preferred wavelength (wavelength of the cosine factor)
%     BANDWIDTH - spatial frequency bandwidth

% read the image in a matrix
% img = imread(img);
if (size(img,3) ~= 1)
  img = rgb2gray(img);
end

% initialize variables
iterations = nors; 
nrtheta = size(theta,2);

% calculate sigma
sigma = calcSigma(sigma, lambda, bandwidth);

% if only one orientation is filled in, create the entire list of
% orientations based on nors. The function is cyclic, therefor
% the values are (for readability) set between [0,2*pi)
if (nrtheta == 1)
  theta(1) = mod(theta(1), 2*pi);
  index = 2; 
  % add orientations to current variable theta
  while (iterations > 1)
    theta(index) = mod(theta(index-1) + (2*pi)/nors, 2*pi);
    iterations = iterations - 1;
    index = index + 1;
  end
else
  theta = mod(theta, 2*pi);
end
theta = unique(theta); % sort the orientations and remove duplicates


% ---------------------------------------------------------------- %
% ---------------- Local function calcSigma ---------------------- %
% ---------------------------------------------------------------- %
function result = calcSigma(sigma, lambda, bandwidth)
% VERSION 19/12/03
% CREATED BY: M.B. Wieling, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% CALCSIGMA: calculates the value of sigma depending on LAMBDA and BANDWIDTH.
%            This calculation is the same as in 'BABORKERNEL2D' and
%            is only carried out when SIGMA contains initially the value 0.
%   CALCSIGMA(SIGMA, LAMBDA, BANDWIDTH) calculates sigma based on
%     SIGMA - the initial value of sigma
%     LAMBDA - the preferred wavelength
%     BANDWIDTH - the spatial frequency bandwidth

% the following calculations are the same as in 'GABORKERNEL2D'
if (sigma == 0)
  slratio = (1/pi) * sqrt( (log(2)/2) ) * ( ((2^bandwidth)+1) / ((2^bandwidth)-1) );
  sigma = slratio * lambda;
end
result = sigma;