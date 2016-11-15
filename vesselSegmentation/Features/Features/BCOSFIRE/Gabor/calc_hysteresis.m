function result = calc_hysteresis(matrix, hyst, tlow, thigh)
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% CALC_HYSTERESIS: returns the thresholded matrix (if HYST is equal to 1) according
% to the hysteresis-method. The parameters used are THIGH and TLOW. Before hysteresis 
% thresholding is (possibly) applied the values of the matrix are scaled between 0 and 1, 
% so the parameters of TLOW and THIGH should also be between 0 and 1.
% A progressbar of the calculations is also shown.
%   CALC_HYSTERESIS(MATRIX, HYST, TLOW, THIGH) calculates the
%   hysteresis-thresholded image acoording to the following parameters
%     MATRIX - the matrix which should be thresholded
%     HYST - if this value is equal to 1, hysteresis thresholding is applied, otherwise 
%            the original matrix (scaled between 0 and 1) is returned
%     TLOW - lower bound for the thresholding (between 0 and 1)
%     THIGH - higher bound for the thresholding (between 0 and 1)

result = matrix;

% apply hysteresis thresholding (result is scaled so thigh & tlow should
% be between 0 and 1)
if (hyst == 1)
  if not(tlow >= thigh | tlow < 0 | tlow > thigh) % no input error
    result = hysthresh(result, thigh, tlow);
  else
    disp('the value(s) of tlow and/or thigh are not correct (correct values: tlow > 0 & thigh < 1 & tlow < thigh)');
  end
end