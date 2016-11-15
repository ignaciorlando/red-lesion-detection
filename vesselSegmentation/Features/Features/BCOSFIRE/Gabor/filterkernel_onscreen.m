function result = filterkernel_onscreen(img, lamda, sigma, theta, phi, gamma, bandwidth, invertOutput)
% VERSION 14/06/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% FILTERKERNEL_ONSCREEN: initializes a matrix with a two dimensional Gabor function and
%           displays this function on the screen.
%   FILTERKERNEL_ONSCREEN(IMG, LAMDA, SIGMA, THETA, PHI, GAMMA, BANDWIDTH) calculates
%     the Gabor function and displays it with the same size of the image.
%     IMG - the image (a filename, e.g. 'lena.jpg')
%     LAMDA - preferred wavelength (wavelength of the cosine factor)
%     SIGMA - standard deviation of Gaussian factor
%     THETA - orientation (specified in radians, i.e. 0.5*pi = 90 deg.)
%     PHI   - phase offset (specified in radians, i.e. 0.5*pi = 90 deg.)
%     GAMMA - spatial aspect ratio (of the x- and y-axis of the Gaussian elipse) 
%     BANDWIDTH - spatial frequency bandwidth - may NOT be 0
%     INVERTOUTPUT - defines if the output should be inverted
%     To use the BANDWIDTH, one of the parameters SIGMA or LAMDA must
%     contain the value 0. SIGMA and LAMDA may NOT contain both the value 0.
%     Otherwise BANDWIDTH is ignored 
%
%   After the matrix is created it is displayed on the screen with (0,0) as 
%   center point of the image. The size of the display is equal to the size
%   of the input image.

% calculate the size of the image
img=imread(img);
h = size(img,1); % height of image
w = size(img,2); % width of image
mxval = max(h,w);

% return a matrix initialized with the Gabor function of size (2N+1 x 2N+1)
filterkernel = gaborkernel2d(lamda, sigma, theta, phi, gamma, bandwidth);

% set the color of the image to gray-scale
colormap('gray');

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

% scale the values in the range [0..1]
minimum = min(min(matrixS));
maximum = max(max(matrixS));
if (minimum ~= maximum)
  matrixS = (matrixS - minimum) / (maximum - minimum);
else
  matrixS = 0;
end

if (invertOutput == 1) % the image should be inverted, precondition values between [0..1]
  matrixS = 1 - matrixS;
end

% set the labels correct for the x-axis and y-axis
x_values = [-extremew,extremew];
y_values = [-extremeh,extremeh];
ylabel = [' 250';' 200';' 150';' 100';'  50';'   0';' -50'; '-100'; '-150'; '-200'; '-250'];

% display the image on the screen with the previously set labels.
imagesc(x_values,y_values,matrixS);
set(gca,'YTick', [-250:50:250]);
set(gca,'YTickLabel', ylabel);
axis image;

result = matrixS;