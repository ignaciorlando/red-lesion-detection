function result = filterkernelpower_onscreen(img, lamda, sigma, theta, phi, gamma, bandwidth, invertOutput)
% VERSION 14/06/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% FILTERKERNELPOWER_ONSCREEN: initializes a matrix with a two dimensional Gabor function (powerspectrum) 
%                             and displays this function on the screen.
%   FILTERKERNELPOWER_ONSCREEN(IMG, LAMDA, SIGMA, THETA, PHI, GAMMA, BANDWIDTH) calculates
%     the powerspectrum of the Gabor function and displays it with the same size of the image.
%     IMG - the image (a filename, e.g. 'lena.jpg')
%     LAMDA - preferred wavelength (wavelength of the cosine factor)
%     SIGMA - standard deviation of Gaussian factor
%     THETA - orientation (specified in radians, i.e. 0.5*pi = 90 deg.)
%     PHI   - phase offset (specified in radians, i.e. 0.5*pi = 90 deg.)
%     GAMMA - spatial aspect ratio (of the x- and y-axis of the Gaussian elipse) 
%     BANDWIDTH - spatial frequency bandwidth - may NOT be 0
%     To use the BANDWIDTH, one of the parameters SIGMA or LAMDA must
%     contain the value 0. SIGMA and LAMDA may NOT contain both the value 0.
%     Otherwise BANDWIDTH is ignored 
%     INVERTOUTPUT - defines if the output should be inverted
%
%   After the matrix is created it is displayed on the screen with (0,0) as 
%   center point of the image. The size of the display is equal to the size
%   of the input image.

% calculate the size of the image
img = imread(img);
h = size(img,1); % height of image
w = size(img,2); % width of image
extremeh = round(h/2);
extremew = round(w/2);

% return a matrix (FILTERKERNEL) initialized with the powerspectrum of the Gabor function of size (2N+1 x 2N+1)
filterpowerresult = calcPowerspectrum(lamda, sigma, theta, phi, gamma, bandwidth, img);

% set the color of the image to gray-scale
colormap('gray');

% scale the values in the range [0..1]
minimum = min(min(filterpowerresult));
maximum = max(max(filterpowerresult));
if (minimum ~= maximum)
  filterpowerresult = (filterpowerresult - minimum) / (maximum - minimum);
else
  filterpowerresult = 0;
end

if (invertOutput == 1) % the image should be inverted, precondition values between [0..1]
  filterpowerresult = 1 - filterpowerresult;
end

% set the labels correct for the x-axis and y-axis
x_values = [-extremew,extremew];
y_values = [-extremeh,extremeh];
ylabel = [' 250';' 200';' 150';' 100';'  50';'   0';' -50'; '-100'; '-150'; '-200'; '-250'];

% display the image on the screen with the previously set labels.
imagesc(x_values,y_values,filterpowerresult);
set(gca,'YTick', [-250:50:250]);
set(gca,'YTickLabel', ylabel);
axis image;

result = filterpowerresult;