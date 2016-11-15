function result = thinning(matrix, oriensMatrix, method)
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% THINNING: reduces the edges to a width of 1 pixel. This is done 
%           by looking at the two pixels next to the current pixel.
%           the neighbourpixels are determined by the orientation of 
%           the current point (this is stored in the exact same location
%           as in the matrix ORIENSMATRIX). A progressbar of the
%           calculations is also shown. 
%   THINNING(MATRIX, ORIENSMATRIX, METHOD) thins the edge
%      MATRIX - the matrix which should be thinned
%      ORIENSMATRIX - the matrix which holds for every pixel of MATRIX the
%                     orientation (in the same position)
%      METHOD - the method of thinning: METHOD == 1: simple method, just
%               take the value of the nearest pixels to compare with.
%               e.g. if the orientation = 20 degrees, the points S & N are chosen
%               to compare to, if the orientation = 25 degrees the points SW & NE
%               are chosen (see below, P = current point)
%                             NW  N  NE
%                             W   P   E
%                             SW  S  SE
%               METHOD == 2: the values to compare with are calculated using
%               interpolation based on the surrounding pixels (NW, N, NE, E, SE, S, SW, W) 

% create the coordinate-system
h = size(matrix,1); % height of image
w = size(matrix,2); % width of image
mx = max(h,w);
[xcoords, ycoords] = meshgrid(1:mx);
xcoords = xcoords(1:h, 1:w);
ycoords = ycoords(1:h, 1:w);

% set every value between 0 and pi
oriensMatrix = mod(oriensMatrix, pi);

% add a border of zeros to 'matrix' and 'oriensMatrix' to ease calculations.
matrixB(h+2,w+2) = 0;
matrixB(2:h+1,2:w+1) = matrix(:,:);
oriensMatrixB(h+2,w+2) = 0;
oriensMatrixB(2:h+1,2:w+1) = oriensMatrix(:,:);

if (method == 1) % simple thinning
  result = 0;
  for I=2:h+1 % the rows
    for J=2:w+1 % the columns
      orien = oriensMatrixB(I,J);
      
      % calculate dx and dy - this is correct as can be seen
      % in a picture
      dx = (orien < (3/8)*pi) - (orien > (5/8)*pi); 
      dy = ((orien > (1/8)*pi) & (orien <= (1/2)*pi)) - ((orien > (1/2)*pi) & (orien < (7/8)*pi));

      % normally the same pixels would be checked if (dy and dx > 0) and (dy and dx < 0). because
      % different pixels should be checked with a gabor-orientation of 45 and 135 this difference should
      % be checked
      if (dy < 0) & (dx < 0)
       result(I,J) = ((matrixB(I,J) >= matrixB(I+dy, J+dx)) & (matrixB(I,J) >= matrixB(I-dy, J-dx))) * matrixB(I,J);  
      else
       result(I,J) = ((matrixB(I,J) >= matrixB(I-dy, J+dx)) & (matrixB(I,J) >= matrixB(I+dy, J-dx))) * matrixB(I,J);  
      end  
    end
  end
else % linear thinning
  %hb = waitbar(0,'Applying linear thinning, please wait ... (Step 6/7)'); % display a progressbar
  result = 0;
  for I=2:h+1 % the rows
    for J=2:w+1 % the columns
      orien = oriensMatrixB(I,J);
      % get the values of the surrounding pixels
      north = matrixB(I-1, J); 
      northeast = matrixB(I-1, J+1); 
      east = matrixB(I, J+1);
      southeast = matrixB(I+1, J+1);
      south = matrixB(I+1, J);
      southwest = matrixB(I+1, J-1);
      west = matrixB(I, J-1);
      northwest = matrixB(I-1, J-1);
    
      % calculate the value of the points in one line (using interpolation)
      if (orien <= (1/4)*pi)
          fraction = orien/((1/4)*pi);
          pnt1 = (1-fraction) * east + (fraction) * northeast;
          pnt2 = (1-fraction) * west + (fraction) * southwest;     
      elseif (orien <= (1/2)*pi)
          fraction = (orien-(1/4)*pi)/((1/4)*pi);
          pnt1 = (1-fraction) * northeast + (fraction) * north;  
          pnt2 = (1-fraction) * southwest + (fraction) * south;
      elseif (orien <= (3/4)*pi)
          fraction = (orien-(1/2)*pi)/((1/4)*pi);
          pnt1 = (1-fraction) * north + (fraction) * northwest;
          pnt2 = (1-fraction) * south + (fraction) * southeast;
      elseif (orien < pi)
          fraction = (orien-(3/4)*pi)/((1/4)*pi);
          pnt1 = (1-fraction) * northwest + (fraction) * west;
          pnt2 = (1-fraction) * southeast + (fraction) * east;
      end  
      result(I,J) = ( (matrixB(I,J) >= pnt1) & (matrixB(I,J) >= pnt2) ) * matrixB(I,J);
    end
    %waitbar(I/h); % update the progressbar
  end
  %close(hb);
end

% removing the borders
result = result(2:h+1, 2:w+1); 