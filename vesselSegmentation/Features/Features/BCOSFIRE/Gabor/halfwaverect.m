function result = halfwaverect(perc, matrix);
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% HALFWAVERECT: applies half-wave rectification using the given percentage (PERC) of the maximum
%               value of MATRIX.
%   HALFWAVERECT(PERC, MATRIX) thresholds
%     PERC - the percentage of the maximum value of MATRIX
%            which should be set to 0. Note that if this value
%            equals NaN, no thresholding is applied. Note also 
%            that every value for the threshold (also 0) has as
%            an effect that all negative values are set to 0
%     MATRIX - the 2-dimensional matrix which should be thresholded

% If there's not-a-number entered (e.g. nothing or a non-digit-character),
% no half-wave rectification is applied.
% If there's a number entered, half-wave rectification should be applied
% so therefor calculate the percentage (of the maximum value) and apply it to the superposition.
% Negative values are rounded to 0, values larger than 100 are rounded to 100
if (isequalwithequalnans(perc,NaN))
  result = matrix; % no half-wave rectification
else
  perc = max((min(perc,100)),0); % percentage is cropped between 0 and 100
  perc_abs = max(max(matrix))*(perc/100);
  result = (matrix>perc_abs).*matrix; % every value > percentage is retained, others are set to 0
end