function result = calc_inhibfacil(matrices, inhibMethod, supInhib, sigma, alpha, k1, k2, facilMethod, beta, f1, f2, orientations, power)
% VERSION 21/03/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% CALC_INHIBFACIL: calculates the anisotropic (INHIBMETHOD == 3) or
% isotropic inhibition (INHIBMETHOD == 2) in combination with the 
% facilitation (if FACILMETHOD == 2) of the matrix.
%   CALC_INHIBFACIL(MATRICES, INHIBMETHOD, SUPINHIB, SIGMA, ALPHA, K1, K2, FACILMETHOD, BETA, F1, F2, ORIENTATIONS, POWER) displays
%   the possibly (if INHIBMETHOD is not equal to 1) inhibited matrix and facilitated matrix (if INHIBMETHOD is not equal to 1)
%   according to the following parameters (a progressbar of the calculations is also shown):
%     MATRICES - the matrices (for each orientation) which should be inhibited
%     INHIBMETHOD - the method of inhibition which is used (INHIBMETHOD == 1: no inhibition and 
%                   MATRICES is returned, INHIBMETHOD == 2: isotropic inhibition, 
%                   INHIBMETHOD == 3: anisotropic inhibition)
%     SUPINHIB - defines the norm which should be used for the superposition which is 
%                only used with isotropic inhibition, there are three possibilities: 
%                L1 norm (SUPINHIB == 1), L2 norm (SUPINHIB == 2) or
%                L_INF norm (SUPINHIB == 3, this is maximum superposition)
%     SIGMA - standard deviation of Gaussian factor
%     ALPHA - defines the suppression of the inhibition
%     K1 - defines the factor for the negative gaussian (second) for the inhibition
%     K2 - defines the factor for the positive gaussian (first) for the inhibition
%     FACILMETHOD - defines if facilitation should be used (if this value ~=1 facilitation is used)
%     BETA - defines the factor of the facilitation
%     F1 - defines the factor for the negative gaussian (second) for the facilitation
%     F2 - defines the factor for the positive gaussian (first) for the facilitation
%     ORIENTATIONS - the list of orientations used for the facilitationkernel (specified in radians)
%     POWER - defines the width of the kernel (the larger this number, the
%             smaller the kernel becomes)

if (inhibMethod ~= 2 & inhibMethod ~=3)
  if (facilMethod == 1)
    result = matrices; % if no inhibition and no facilitation is selected, return the original MATRICES
  else % no inhibition, only facilitation
    % display a waitbar
    %h = waitbar(0,'Calculating surround facilitation, please wait... (Step 4/7)');
  
    % apply the inhibition with the correct inhibitionterm (2nd parameter)
    for cnt1 = 1:size(matrices,3)
      %waitbar(cnt1/size(matrices,3)); % update the progressbar
      result(:,:,cnt1) = facilitation(matrices(:,:,cnt1), matrices(:,:,cnt1), sigma, beta, f1, f2, orientations(cnt1), power);
    end
    %waitbar(1);
    %close(h);
  end
else % inhibition is enabled
  % calculate the inhibitionterm (only if isotropic inhibition is used)
  if (inhibMethod == 2) 
    % initialize the starting values
    if (supInhib == 3) 
      inhibterm = -inf; % starting value for maximum superposition (every value > -Inf)
    else
      inhibterm = 0;
      tmpinhibterm = 0;
    end
    
    for cnt1 = 1:size(matrices,3)
      if (supInhib == 1)
        inhibterm = inhibterm + abs(matrices(:,:,cnt1));
      elseif (supInhib == 2)
        % first calculate X1^2 + X2^2 + XN^2, the square-root is taken after the loop
        tmpinhibterm  = tmpinhibterm + matrices(:,:,cnt1).*matrices(:,:,cnt1);
      else
        inhibterm = max(abs(matrices(:,:,cnt1)), inhibterm);
      end
    end
  
    % if the L2 norm was chosen, the square-root should be taken
    % since L2 = SQRT(X1^2 + X2^2 + ... XN^2)
    if (supInhib == 2) 
      inhibterm = sqrt(tmpinhibterm);
    end
  end
  
  % calculate the inhibitionkernel which remains the same for each orientation
  inhibkernel = inhibkernel2d(sigma, k1, k2); 
  
  if (facilMethod == 1) % no facilitation, only inhibition
    % display a waitbar
    %h = waitbar(0,'Calculating surround inhibition, please wait... (Step 4/7)');
    
    % apply the inhibition with the correct inhibitionterm (2nd parameter)
    for cnt1 = 1:size(matrices,3)
      %waitbar(cnt1/size(matrices,3)); % update the progressbar
      if (inhibMethod == 3) % anisotropic inhibition
        result(:,:,cnt1) = inhibition(matrices(:,:,cnt1), matrices(:,:,cnt1), inhibkernel, alpha);
      elseif (inhibMethod == 2) % isotropic inhibition
        result(:,:,cnt1) = inhibition(matrices(:,:,cnt1), inhibterm, inhibkernel, alpha);
      end
    end
    %waitbar(1);
    %close(h);
    
  else
    % display a waitbar
    %h = waitbar(0,'Calculating surround influence, please wait... (Step 4/7)');
    
    % apply the inhibition and facilitation
    for cnt1 = 1:size(matrices,3)
      %waitbar(cnt1/size(matrices,3)); % update the progressbar
      if (inhibMethod == 3) % anisotropic inhibition
        result(:,:,cnt1) = inhibfacil(matrices(:,:,cnt1), matrices(:,:,cnt1), inhibkernel, matrices(:,:,cnt1), sigma, alpha, beta, f1, f2, orientations(cnt1), power);
      elseif (inhibMethod == 2) % isotropic inhibition
        result(:,:,cnt1) = inhibfacil(matrices(:,:,cnt1), inhibterm, inhibkernel, matrices(:,:,cnt1), sigma, alpha, beta, f1, f2, orientations(cnt1), power);
      end
    end
    %waitbar(1);
    %close(h);
  end
end