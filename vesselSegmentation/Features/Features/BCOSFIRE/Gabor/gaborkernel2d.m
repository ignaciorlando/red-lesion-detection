function result = gaborkernel2d(lambda, sigma, theta, phi, gamma, bandwidth)
% VERSION 2004-04-05
% CREATED BY: N. Petkov and M.B. Wieling, Groningen University
%
% GABORKERNEL2D(LAMBDA, SIGMA, THETA, PHI, GAMMA, BANDWIDTH) 
%   fills a (2N+1)*(2N+1) matrix with the values of a 2D Gabor function. N is computed from SIGMA.
%     LAMBDA - preferred wavelength (period of the cosine factor) [in pixels]
%     SIGMA - standard deviation of the Gaussian factor [in pixels]
%     THETA - preferred orientation [in radians]; can be a 1D array 
%     PHI   - phase offset [in radians] of the cosine factor; can be a 1D array
%     GAMMA - spatial aspect ratio (of the x- and y-axis of the Gaussian elipse)
%     BANDWIDTH - spatial frequency bandwidth at half response,
%       BANDWIDTH, SIGMA and LAMBDA are interdependent. To use BANDWIDTH, 
%       the input value of one of SIGMA or LAMBDA must be 0. Otherwise BANDWIDTH is ignored.
%       The actual value of the parameter whose input value is 0 is computed inside the 
%       function from the input vallues of BANDWIDTH and the other parameter.

theta = theta(1); % if theta is an array, only the first value is used
phi = phi(1); % if phi is an array, only the first value is used

% calculation of the ratio sigma/lambda from BANDWIDTH 
% according to Kruizinga and Petkov, 1999 IEEE Trans on Image Processing 8 (10) p.1396
% note that in Matlab log means ln 
slratio = (1/pi) * sqrt( (log(2)/2) ) * ( (2^bandwidth + 1) / (2^bandwidth - 1) );
% e.g. BANDWITH = 1 will result in the slratio = 0.56

% test if the sigma/lambda ratio is to be used and set sigma or lambda to the correct value
if (sigma == 0)
  sigma = slratio * lambda;
elseif (lambda == 0)
  lambda = sigma / slratio;
end

% compute the size of the 2n+1 x 2n+1 matrix to be filled with the values of a Gabor function
% this size depends on sigma and gamma
if (gamma <= 1 & gamma > 0)
	n = ceil(2.5*sigma/gamma);
else
	n = ceil(2.5*sigma);
end

% creation of two (2n+1) x (2n+1) matrices x and y that contain the x- and y-coordinates of
% a square 2D-mesh; the rows of x and the columns of y are copies of the vector -n:n
[x,y] = meshgrid(-n:n);

% change direction of y-axis (In Matlab the vertical axis corresponds to the row index
% of a matrix. If the y-coordinates run from -n to n, the lowest value (-n) comes
% in the top row of the matrix ycoords and the highest value (n) in the
% lowest row. This is oposite to the customary rendering of values on the y-axis: lowest value 
% in the bottom, highest on the top. Therefore the y-axis is inverted:
y = -y;

% xp and yp are the coordinates of a point in a coordinate system rotated by theta.
% They are the main axes of the elipse of the Gaussian factor of the Gabor function.
% The wave vector of the Gabor function is along the xp axis.
xp =  x * cos(theta) + y * sin(theta);
yp = -x * sin(theta) + y * cos(theta);

% precompute coefficients gamma2=gamma*gamma, b=1/(2*sigma*sigma) and spacial frequency
% f = 2*pi/lambda to prevent multiple evaluations 
gamma2 = gamma*gamma;
b = 1 / (2*sigma*sigma);
a = b / pi;
f = 2*pi/lambda;

% filling (2n+1) x (2n+1) matrix result with the values of a 2D Gabor function
cosineFunction = cos(f*xp + phi);
result = a*exp(-b*(xp.*xp + gamma2*(yp.*yp))) .* cosineFunction;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NORMALIZATION of positive and negative values to ensure that the integral of the kernel is 0.
% This is needed when phi is different from pi/2.
ppos = find(result > 0); %pointer list to indices of elements of result which are positive
pneg = find(result < 0); %pointer list to indices of elements of result which are negative 

pos =     sum(result(ppos));  % sum of the positive elements of result
neg = abs(sum(result(pneg))); % abs value of sum of the negative elements of result

result(ppos) = result(ppos) / pos;
result(pneg) = result(pneg) / neg;

% meansum = (pos+neg)/2;
% if (meansum > 0) 
%     pos = pos / meansum; % normalization coefficient for negative values of result
%     neg = neg / meansum; % normalization coefficient for psoitive values of result
% end
% 
% result(pneg) = pos*result(pneg);
% result(ppos) = neg*result(ppos);

%another normalization step;
% result = result ./ sum(result(find(result > 0)));