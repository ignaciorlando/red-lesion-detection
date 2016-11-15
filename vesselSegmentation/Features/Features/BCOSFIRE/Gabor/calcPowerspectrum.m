function result = calcPowerspectrum(lambda, sigma, theta, phi, gamma, bandwidth, img)
% VERSION 07/05/04
% CREATED BY: M.B. Wieling, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% CALCPOWERSPECTRUM: calculates the power spectrum of the gaborfilter, which is calculated
%                    using the supplied parameters 
% 
%   CALCPOWERSPECTRUM(LAMBDA, SIGMA, THETA, PHI, GAMMA, BANDWIDTH, IMG) returns a powerspectrum of the Gabor function with
%     LAMBDA - preferred wavelength (period of the cosine factor)
%     SIGMA - standard deviation of the Gaussian factor
%     THETA - preferred orientation
%     PHI   - phase offset
%     GAMMA - spatial aspect ratio (of the x- and y-axis of the Gaussian elipse)
%     BANDWIDTH - spatial frequency bandwidth at half response
%     IMG - a matrix with the original image
%     To use the BANDWIDTH, one of the parameters SIGMA or LAMBDA must
%     contain the value 0. Otherwise BANDWIDTH is ignored.

filterkernel = gaborkernel2d(lambda, sigma, theta, phi, gamma, bandwidth);

% First crop or pad the FILTERKERNEL with 0's to correspond to a square
% of min(width(IMG), height(IMG))^2. In this way the powerspectrum will always be taken 
% over the same square-sized FILTERKERNEL (for one image). 
hi = size(img,1); % height of image
wi = size(img,2); % width of image

% make sure the powerspectrum is taken of a square with size min(height,width)^2
minval = min(hi,wi);
h = minval;
w = minval;
mxval = max(h,w);

% The value of N represents the maximum value 
% of the x-axis and y-axis. -N represents the minimum value of the x-axis
% and y-axis (due to the symmetry). 
% Here it is used to display the correct values next to the x- and y-axis
% E.g. if N=5 the x- and y-axis will run from -5 to 5. 
% Since the size in both directions of the filterkernel is 2*N-1 the value of N can be easily
% calculated
n = (size(filterkernel,1) - 1)/2;

% create a 'h' x 'w' matrix with 0's 
matrixS = zeros(mxval);
matrixS = matrixS(1:h, 1:w);

% calculate where the filterkernel in this matrix should be placed to be centered
% therefor we have to calculate the center of matrixS & subtract (begin) or add (end)
% the half of the size of the filterkernel (=n). We have to add 1 because the index starts 
% at 1. We have to adhere to the fact the minimum value of startv = size(matrixS) / 2
% The maximum values (extremeh & extremew) are stored because they areused several times
% the minimum value is -extreme+1 (negative y-axis is 1 smaller than positive y-axis)
extremeh = round(h/2);
extremew = round(w/2);
startvh = max(1, extremeh - n + 1); % startv cannot be < 1
startvw = max(1, extremew - n + 1); % startv cannot be < 1
endvh = min(2*extremeh, extremeh + n + 1); % endv cannot be larger than the total size of matrixS
endvw = min(2*extremew, extremew + n + 1); % endv cannot be larger than the total size of matrixS

% place the filterkernel in the center of matrixS, if the filterkernel is larger than matrixS
% the filterkernel is cropped in matrixS. The overlap (evenly on all sides)
% - calculated by the difference between the maxima (n and extremeh & extremew)
% is cut of so that the middle of the filterkernel is still at (0,0).
overlaph = max(0,n - extremeh); % if there is overlap this value > 0
overlapw = max(0,n - extremew); % if there is overlap this value > 0
if (overlaph <= 0) & (overlapw <= 0) % there is no overlap so the filterkernel fits in matrixS    
  matrixS(startvh:endvh, startvw:endvw) = filterkernel;
elseif (overlaph <= 0) & (overlapw > 0) % there is overlap on the left and right side: crop
  startindexw = 1 + overlapw;
  endindexw = 2*extremew + overlapw;
  matrixS(startvh:endvh, startvw:endvw) = filterkernel(:, startindexw:endindexw);
elseif (overlaph > 0) & (overlapw <= 0) % there is overlap on the top and bottom side: crop
  startindexh = 1 + overlaph;
  endindexh = 2*extremeh + overlaph;
  matrixS(startvh:endvh, startvw:endvw) = filterkernel(startindexh:endindexh, :);
else % filterkernel > matrixS so we have to crop it
  startindexh = 1 + overlaph;
  endindexh = 2*extremeh + overlaph;
  startindexw = 1 + overlapw;
  endindexw = 2*extremew + overlapw;
  matrixS(startvh:endvh, startvw:endvw) = filterkernel(startindexh:endindexh, startindexw:endindexw);
end

% calculate powerspectrum
powerresult = abs(ifftshift(fft2(fftshift(matrixS)))).^2;

% put the previous result in the size of the original image
if (h < hi)
  difh = hi-h;
  if (mod(difh,2) == 0)
    % difh is even, so can be divided by two
    result = padarray(powerresult, (difh/2));
  else
    % difh is odd so if one half is rounded and one half is floored it 
    % summs to difh
    result = padarray(powerresult, fix(difh/2), 'pre');
    result = padarray(result, round(difh/2), 'post');
  end
elseif (w < wi)
  difw = wi-w;
  if (mod(difw,2) == 0)
    % difw is even, so can be divided by two
    result = transpose(padarray(transpose(powerresult), (difw/2)));
  else
    % difw is odd so if one half is rounded and one half is floored it 
    % summs to difw
    result = padarray(transpose(powerresult), fix(difw/2), 'pre');
    result = transpose(padarray(result, round(difw/2), 'post'));
  end
else
  result = powerresult;
end