function result = calc_halfwaverect(matrices, theta, phi, hwperc)
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% CALC_HALFWAVERECT: calculates all half-wave rectifications of the matrices
% stored in the 4-dimensional matrix MATRICES. Half-wave rectification is calculated of 
% a percentage of the maximum value stored in each 2-dimensional matrix.
% A progressbar of the calculations is also shown.
%   CALC_HALFWAVERECT(MATRICES, THETA, PHI, HWPERC) with the following parameters:
%     MATRICES - the matrices which should be half-wave rectified
%     THETA - list of all orientations
%     PHI - list of all phase-offsets              
%     HWPERC - half-wave rectification is calculated according to a percentage of the maximum
%              value, all values below the percentage are set to 0, the rest remains
%              unchanged (e.g. percentage of 10: every value below 10% of the maximum value
%              is set to 0, percentage of 100: only the maximum value is retained)
%              note that if half-wave rectification is applied (a numerical value is stored in
%              HWPERC) the negative values are ALWAYS set to 0 (e.g. a percentage of 0 
%              only sets the negative values to 0)

if (isequalwithequalnans(hwperc,NaN)) % if a non-numerical value is entered, return the original matrix
  result = matrices;
else
  % display a progressbar
  %h = waitbar(0,'Calculating half-wave rectification, please wait... (Step 2/7)');
  
  % initialise values
  nrtheta = size(theta,2);
  nrphi = size(phi,2);

  % calculate all half-wave rectifications
  cnt1 = 1;
  while (cnt1 <= nrtheta)
    cnt2 = 1;
    while (cnt2 <= nrphi) % for each phi the convolution is calculated
      result(:,:,cnt2,cnt1) = halfwaverect(hwperc, matrices(:,:,cnt2,cnt1));
      cnt2 = cnt2 + 1;
    end
    cnt1 = cnt1 + 1;
    %waitbar(cnt1/nrtheta); % update the progressbar
  end
  %close(h);
end