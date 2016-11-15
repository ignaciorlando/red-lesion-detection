function result = inhibkernel2d(sigma, k1, k2)
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% INHIBKERNEL2D: creates the inhibitionkernel
%   INHIBITION(SIGMA, K1, K2) with the following parameters
%     SIGMA - the standard deviation for the Gaussian function
%     K1 - defines the factor for the negative gaussian (second)
%     K2 - defines the factor for the positive gaussian (first) 

diff_of_gauss = diffOfGausskernel2d(sigma, k1, k2); % construct the DoG convolution kernel
diff_of_gauss = diff_of_gauss .* (diff_of_gauss > 0); % set every negative value to 0 (H-function)

norm_L1 = sum(sum(abs(diff_of_gauss)));
if (norm_L1 ~= 0)
  result = diff_of_gauss / norm_L1; % create the normalized weighting function (normalisation according to L1-norm)
else
  result = 0;
end