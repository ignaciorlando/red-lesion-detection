function [padded, biggerMask] = fakepad(img, mask, erosionsize, iterations)
% padded = fakepad(img, mask, erosionsize, iterations)
%
% Creates an artificial region in the area outside the
% mask. "iterations" is the number of times a one-pixel border is
% added to the image, i.e. the size of the padding created.

%
% Copyright (C) 2006  João Vitor Baldini Soares
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor,
% Boston, MA 02110-1301, USA.
%

% Default parameters.
if(nargin == 2)
  erosionsize = 5;
  iterations = 50;
end

% Contour before erosion
% ///
[nrows, ncols] = size(mask);
biggerMask = zeros(nrows + 2 * iterations, ncols + 2 * iterations);
biggerMask(iterations:end-iterations-1, iterations:end-iterations-1) = mask;
mask = biggerMask;
[nrows, ncols] = size(mask);
mask(1,:) =     zeros(1, ncols);
mask(nrows,:) = zeros(1, ncols);
mask(:,1) =     zeros(nrows, 1);
mask(:,ncols) = zeros(nrows, 1);

[nrows, ncols] = size(img);
biggerImage = zeros(nrows + 2 * iterations, ncols + 2 * iterations);
biggerImage(iterations:end-iterations-1, iterations:end-iterations-1) = img;
img = biggerImage;
[nrows, ncols] = size(img);
% ///


% Erodes the mask to avoid weird region near the border.
mask = imerode(mask, strel('disk', erosionsize, 0));

dilated = img .* double(mask);

oldmask = mask;

filter = [1 1 1; 
          1 1 1;
          1 1 1];
[filterrows, filtercols] = find(filter > 0);
filterrows = filterrows - 2;
filtercols = filtercols - 2;

for i = 1:iterations
  % finds pixels on the outer border
  newmask = imdilate(oldmask, strel('diamond', 1));
  outerborder = newmask & ~oldmask;

  [rows, cols] = find(outerborder);
  % grows into the outer border.
  for j = 1:size(cols, 1)
    col = cols(j);
    row = rows(j);

    filtered = [];
    for k = 1:size(filtercols, 1)
      filtercol = filtercols(k);
      filterrow = filterrows(k);
      
      pixelrow = row + filterrow;
      pixelcol = col + filtercol;
      if (pixelrow <= nrows & pixelrow >= 1 & pixelcol <= ncols & ...
          pixelcol >= 1 & oldmask(pixelrow, pixelcol))
        filtered = [filtered dilated(pixelrow, pixelcol)];
      end
    end
    % Mean of values under the filter.
    dilated(row, col) = sum(filtered)/length(filtered);
  end

  oldmask = newmask;
end

padded = dilated;