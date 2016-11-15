function result = inhibition(matrix, inhibterm, inhibkernel, alpha)
% VERSION 21/03/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% INHIBITION: applies surround inhibition to the MATRIX according to the other
%             parameters.
%   INHIBITION(MATRIX, INHIBTERM, INHIBKERNEL, ALPHA) with the following parameters
%     MATRIX - the matrix to which surround inhibition should be applied
%     INHIBTERM - the matrix which is the inhibition term
%     INHIBKERNEL - the inhibitionkernel (based on sigma, k1 and k2)
%     ALPHA - defines the suppression of the inhibition

if (alpha == 0)
  b = matrix; % no inhibition
else 
%   w = inhibkernel2D(sigma, k1, k2); % calculate the inhibitionkernel
%   t = convolution(inhibterm, w); % calculate the inhibitionterm
%   b = matrix - alpha*t; % apply the surround inhibition according to the suppression factor ALPHA
  t = convolution(inhibterm, inhibkernel);
  b = matrix - alpha*t;
end
result = (b.*(b>0)); % set every negative value to 0 (H-function)