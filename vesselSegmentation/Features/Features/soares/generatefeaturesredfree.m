function [description, features] = generatefeaturesredfree(img, mask, ...
                                                  scales, paderosionsize)
% [description, features] = generatefeaturesredfree(img, mask, scales,
% paderosionsize)
%
% Generates features for red-free "img". The region of interest
% (camera's aperture) is indicated in "mask".  "scales" is a vector
% indicating what scales of the Morlet wavelet are used for
% features. "paderosionsize" indicates the size of the erosion
% performed before extending the image with our padding. Returns a
% three-dimensional double matrix indexed by (x, y, c), where (x, y)
% is the pixel's position in the image and (c) is a feature.
% "description" is a matrix of vector strings indexad by the features
% (c), containing their description.

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

img = double(img) / 255;

% Inverting so vessels become brighter.
img = 1 - img;

% Makes the image larger before creating artificial extension, so the
% wavelet doesn't have border effects
[sizey, sizex] = size(img);

bigimg = zeros(sizey + 100, sizex + 100);
bigimg(51:(50+sizey), 51:(50+sizex)) = img;

bigmask = logical(zeros(sizey + 100, sizex + 100));
bigmask(51:(50+sizey), (51:50+sizex)) = mask;

% Creates artificial extension of image.
bigimg = fakepad(bigimg, bigmask, paderosionsize, 80);

description = 'Inverted gray image';
features = bigimg(51:(50+sizey), (51:50+sizex));

disp(description);

% Below, creates the maximum wavelet response over angles and adds
% them as pixel features
fimg = fft2(bigimg);

k0x = 0;

for k0y = [3]
  for a = scales
    for epsilon = [8]
      % Maximum transform over angles.
      trans = maxmorlet(fimg, a, epsilon, [k0x k0y], 10);
      trans = trans(51:(50+sizey), (51:50+sizex));
      
      % Adding to features
      features = cat(3, features, trans);
      
      des = ['Morlet a = ' num2str(a) ', k0y = ' num2str(k0y)...
             ', eps = ' num2str(epsilon)];
      
      %figure; imshow(trans, []); title(des);
      
      description = strvcat(description, des);
      
      disp(des);
    end
  end
end