function result = gaussian2d(x, y, sigma)
% VERSION 5/1/04
% CREATED BY: R. Hof, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% EDITED BY: M.B. Wieling, Groningen University,
%            Department of Computer Science, Intelligent Systems
%
% GAUSSIAN2D returns the Gaussian function with standard
% deviation SIGMA at each location (X(i), Y(i)).
%   GAUSSIAN2D(X, Y, SIGMA) returns the Gaussian function)
%     X - a matrix of x-values
%     Y - a matrix of y-values
%     SIGMA - standard deviation of Gaussian factor

% use constants to speed up processing
sigmatmp = 2*sigma*sigma;
sigmatmp2 = 2*pi*sigma*sigma;

% calculate the gaussian
result = exp(-(x.*x + y.*y) / (sigmatmp)) / (sigmatmp2);