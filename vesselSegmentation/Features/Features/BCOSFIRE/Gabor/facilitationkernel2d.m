function result = facilitationkernel2d(sigma, f1, f2, orientation, power)
% VERSION 21/03/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% FACILITATIONKERNEL2D: creates the facilitationkernel
%   FACILITATIONKERNEL2D(SIGMA, F1, F2, POWER) with the following parameters
%     SIGMA - the standard deviation for the Gaussian function
%     F1 - defines the factor for the negative gaussian (second)
%     F2 - defines the factor for the positive gaussian (first)
%     ORIENTATION - defines the orientation of the kernel (between 0 and pi)
%     POWER - defines the width of the kernel (the larger this number, the
%             smaller the kernel becomes)

diff_of_gauss = diffOfGausskernel2d(sigma, f1, f2); % construct the DoG convolution kernel
diff_of_gauss = diff_of_gauss .* (diff_of_gauss > 0); % set every negative value to 0 (H-function)

norm_L1 = sum(sum(abs(diff_of_gauss)));
if (norm_L1 ~= 0)
  result = diff_of_gauss / norm_L1; % create the normalized weighting function (normalisation according to L1-norm)
else
  result = 0;
end

% translation to center-based coordinates by subtracting the value
% of the middle coordinate
middle = ceil(size(result,1)/2);

% create the new kernel (vertical)
for Y = 1:size(result,1)
  for X = 1:size(result,2)
     if ((X-middle) ~= 0)
       % calculate the x and y coordinate in a graph with center (0,0)
       Yim = Y-middle;
       Xim = X-middle; 
       result(Y,X) = ((Yim*Yim)^power / (Xim*Xim + Yim*Yim)^power) * result(Y,X);
     end
  end
end  

% rotate the kernel to the correct orientation
result = imrotate(result, orientation(1)*(180/pi), 'bilinear', 'loose');