function result = calc_phasessuppos(matrices, theta, phi, supPhases)
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% CALC_PHASESSUPPOS: calculates the superposition of phases for each orientation 
% as stored in MATRICES. This results in a 3-dimensional matrix which is returned 
% (for each orientation one matrix with values).
% A progressbar of the calculations is also shown.
%   CALC_PHASESSUPPOS(MATRICES, THETA, PHI, SUPPHASES) calculates the superposition 
%   according to the following parameters:
%     MATRICES - the matrices which hold all the convolutions for each combination of phase and
%                orientation. The superposition of all the matrices belonging to the same
%                orientation is calculated 
%     THETA - a list of all the orientations
%     PHI   - a list of all the phase-offsets              
%     SUPPHASES - defines the norm which should be used for the superposition of all the phases
%                 belonging to a single orientation. There are three possibilities: L1 norm 
%                 (SUPPHASES == 1), L2 norm (SUPPHASES == 2) or L_INF norm (SUPPHASES == 3, 
%                 this is maximum superposition). If SUPPHASES == 4, there is no phase
%                 superposition applied

nrtheta = size(theta,2);

% if no superposition is applied return the matrices belonging to the FIRST phase (in PHI)
if (supPhases == 4)
   cnt1 = 1;
   while (cnt1 <= nrtheta)
     result(:,:,cnt1) = matrices(:,:,1,cnt1);
     cnt1 = cnt1 + 1;
   end
else
  % display a progressbar
  %h = waitbar(0,'Applying superposition of phases, please wait ... (Step 3/7)');
  
  % calculate for each orientation the superpositions of all the phase-matrices belonging to that
  % orientation
  nrphi = size(phi,2);
  cnt1 = 1;
  while (cnt1 <= nrtheta)
    cnt2 = 1;
    % initialize the values of the result-variables
    if (supPhases == 3) 
      resultP = -inf; % starting value for maximum superposition (every value > -Inf)
    else
      resultP = 0;
      tmpresultP = 0;
    end
    
    while (cnt2 <= nrphi)
      % calculate the superposition of all phases for 1 orientation
      % according to the method defined in supPhases
      if (supPhases == 1) % L1 norm
        resultP = resultP + abs(matrices(:,:,cnt2,cnt1));
      elseif (supPhases == 2) % L2 norm
        % first calculate X1^2 + X2^2 + XN^2, the square-root is taken after the loop
        tmpresultP = tmpresultP + matrices(:,:,cnt2,cnt1).*matrices(:,:,cnt2,cnt1);
      else % maximum superposition
        resultP = max(abs(matrices(:,:,cnt2,cnt1)), resultP);
      end
      cnt2 = cnt2 + 1;
    end
  
    % if the L2 norm was chosen, the square-root should be taken
    % since L2 = SQRT(X1^2 + X2^2 + ... XN^2)
    if (supPhases == 2) 
      resultP = sqrt(tmpresultP);
    end
    
    result(:,:,cnt1) = resultP; % store all the matrices for each orientation 
    
    %waitbar(cnt1/nrtheta); % update the progressbar
    cnt1 = cnt1 + 1;
  end
  %close(h);
end