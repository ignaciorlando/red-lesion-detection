function result = diffOfGausskernel2d(sigma, k1, k2)
% VERSION 5/1/04
% CREATED BY: R. Hof, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% EDITED BY: M.B. Wieling, Groningen University,
%            Department of Computer Science, Intelligent Systems
%
% DIFFOFGAUSSKERNEL2D constructs a DoG convolution kernel
%   DIFFOFGAUSSKERNEL2D(SIGMA, K1, K2) constructs a convolution kernel, a matrix (not normalized)
%     SIGMA - standard deviation of Gaussian factor
%     K1 - defines the factor for the second gaussian
%     K2 - defines the factor for the first gaussian


% The filter is constructed by sampling the difference of Gaussian
% function (DoG) at every integer point. As
% the function is almost zero at SIGMA*(3*K1 + K2) from the origin, sampling
% at integer points at at most this distance from the origin suffices.

n = ceil(sigma)*(3*k2 + k1) - 1; % filter size is n to left and n to right from filter center
[x, y] = meshgrid(-n:n); % create a matrix (x,y) with the coordinates of the sample points

% apply the DoG function to each sample point
result = gaussian2d(x, y, k2*sigma) - gaussian2d(x, y, k1*sigma);