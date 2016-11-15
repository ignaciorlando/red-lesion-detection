function result = calc_thinning(matrix, oriensMatrix, thin)
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% CALC_THINNING: if THIN is equal to 1 it returns the thinned matrix,
% otherwise the original matrix (MATRIX is returned). The thinning is 
% done based on the maximum orientation response (as is stored for 
% each point in ORIENSMATRIX - this is calculated in CALC_VIEWIMAG.
% A progressbar of the calculations is created and updated in THINNING.
%   CALC_THINNING(MATRIX, ORIENSMATRIX, THIN) calculates the
%   thinned matrix (according to a linear interpolation method).
%     MATRIX - the matrix which should be thinned
%     ORIENSMATRIX - a matrix which has the same size as MATRIX and has for
%                    each point the orientation (between 0 and 2*pi) which 
%                    had the maximum response for the convolution
%     THIN - apply thinning if this value is equal to 1, otherwise
%            the original matrix is returned

% thinning should be applied, if the third parameter is 1, a simple
% thinning method is applied, otherwise a linear interpolation method is
% applied
if (thin == 1) 
  result = thinning(matrix, oriensMatrix, 2);
else
  result = matrix;
end