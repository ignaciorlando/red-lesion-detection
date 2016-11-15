function result = facilitation(matrix, facilterm, sigma, beta, f1, f2, orientation, power)
% VERSION 21/03/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% FACILITATION: applies surround facilitation to the MATRIX according to the other
%             parameters.
%   FACILITATION(MATRIX, FACILTERM, SIGMA, BETA, F1, F2, ORIENTATION, POWER) with the following parameters
%     MATRIX - the matrix to which surround facilitation should be applied
%     FACILTERM - the matrix which is the facilitation term
%     SIGMA - the standard deviation for the Gaussian function
%     BETA - defines the factor of the facilitation
%     F1 - defines the factor for the negative gaussian (second)
%     F2 - defines the factor for the positive gaussian (first)
%     ORIENTATION - the orientation for this matrix (specified in radians)
%     POWER - defines the width of the kernel (the larger this number, the
%             smaller the kernel becomes)

if (beta == 0)
  b = matrix; % no inhibition
else 
  w = facilitationkernel2D(sigma, f1, f2, orientation, power); % calculate the facilitationkernel
  t = convolution(facilterm, w); % calculate the facilitationterm
  b = matrix + beta*t; % apply the surround facilitation according to the facilitation factor BETA (+ instead of - (with inhibition))
end
result = (b.*(b>0)); % set every negative value to 0 (H-function)