function result = facilkernel_onscreen(img, sigma, f1, f2, perc, orientation, power, invertOutput)
% VERSION 14/06/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% FACILKERNEL_ONSCREEN: displays the facilitationkernel on the screen in the
%   same size as the image. The facilitationkernel is half-wave rectified before
%   display.
%   FACILKERNEL_ONSCREEN(IMG, SIGMA, F1, F2, PERC, ORIENTATION, POWER) with the following parameters
%     IMG - the image (a filename, e.g. 'lena.jpg')
%     SIGMA - the standard deviation for the Gaussian function
%     F1 - defines the factor for the negative gaussian (second)
%     F2 - defines the factor for the positive gaussian (first)
%     PERC - the half-wave rectification percentage
%     ORIENTATION - the orientation of the kernel (between 0 and pi)
%     POWER - defines the width of the kernel (the larger this number, the
%             smaller the kernel becomes)
%     INVERTOUTPUT - defines if the output should be inverted

% calculate the size of the image
img=imread(img);
h = size(img,1); % height of image
w = size(img,2); % width of image
mxval = max(h,w);

% return a matrix initialized with the facilitationkernel of size 2*N+1
facilkernel = facilitationkernel2D(sigma, f1, f2, orientation, power);

% apply half-wave rectification
facilkernel = halfwaverect(perc,facilkernel);

% Set the color of the image to gray-scale
colormap('gray');

% The value of N represents the maximum value 
% of the x-axis and y-axis. -N represents the minimum value of the x-axis
% and y-axis (due to the symmetry). 
% Here it is used to display the correct values next to the x- and y-axis
% E.g. if N=5 the x- and y-axis will run from -5 to 5. 
% Since the size in both directions of the facilkernel is 2*N-1 the value of N can be easily
% calculated.
n = (size(facilkernel,1) - 1)/2;

% create a 'h' x 'w' matrix with 0's 
matrixS = zeros(mxval);
matrixS = matrixS(1:h, 1:w);

% calculate where the facilkernel in this matrix should be placed to be centered
% therefor we have to calculate the center of matrixS & subtract (begin) or add (end)
% the half of the size of the facilkernel (=n). We have to add 1 because the index starts 
% at 1. We have to adhere to the fact the minimum value of startv = size(matrixS) / 2
% The maximum values (extremeh & extremew) are stored because they areused several times
% the minimum value is -extreme+1 (negative y-axis is 1 smaller than positive y-axis)
extremeh = round(h/2);
extremew = round(w/2);
startvh = round(max(1, extremeh - n + 1)); % startv cannot be < 1
startvw = round(max(1, extremew - n + 1)); % startv cannot be < 1
endvh = round(min(h, extremeh + n + 1));% endv cannot be larger than the total size of matrixS
endvw = round(min(w, extremew + n + 1)); % endv cannot be larger than the total size of matrixS

% place the facilkernel in the center of matrixS, if the facilkernel is larger than matrixS
% the facilkernel is cropped in matrixS. The overlap (evenly on all sides)
% - calculated by the difference between the maxima (n and extremeh & extremew)
% is cut of so that the middle of the facilkernel is still at (0,0).
overlaph = round(max(0,size(facilkernel,1) - h)/2); % if there is overlap this value > 0
overlapw = round(max(0,size(facilkernel,2) - w)/2); % if there is overlap this value > 0

if (overlaph <= 0) & (overlapw <= 0) % there is no overlap so the facilkernel fits in matrixS
  matrixS(startvh:endvh, startvw:endvw) = facilkernel;
elseif (overlaph <= 0) & (overlapw > 0) % there is overlap on the left and right side: crop
  startindexw = 1 + overlapw;
  endindexw = 2*extremew + overlapw;
  matrixS(startvh:endvh, startvw:endvw) = facilkernel(:, startindexw:endindexw);
elseif (overlaph > 0) & (overlapw <= 0) % there is overlap on the top and bottom side: crop
  startindexh = 1 + overlaph;
  endindexh = 2*extremeh + overlaph;
  matrixS(startvh:endvh, startvw:endvw) = facilkernel(startindexh:endindexh, :);
else % facilkernel > matrixS so we have to crop it
  startindexh = 1 + overlaph;
  endindexh = 2*extremeh + overlaph;
  startindexw = 1 + overlapw;
  endindexw = 2*extremew + overlapw;
  matrixS(startvh:endvh, startvw:endvw) = facilkernel(startindexh:endindexh, startindexw:endindexw);
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