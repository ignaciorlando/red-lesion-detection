function [features] = Soares2006(I, mask, unary, options)
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


% Set parameters
if (~exist('options','var'))
    scales = [2 3 4 5];
else
    scales = options.scales;
end

if (~isfield(options, 'dontpreprocess'))
    I = double(I) - double(medfilt2(uint8(I), [50 50]));
    I = (double(I) - min(I(:))) / (max(I(:)) - min(I(:)));
end

% Inverting so vessels become brighter.
I = 1 - I;

features = [];

% Below, creates the maximum wavelet response over angles and adds
% them as pixel features
bigimg = I;
fimg = fft2(bigimg);

k0x = 0;

for k0y = [3]
  for a = scales
    for epsilon = [4]
      % Maximum transform over angles.
      trans = maxmorlet(fimg, a, epsilon, [k0x k0y], 10);
      
      % Adding to features
      features = cat(3, features, trans);
    end
  end
end

if (~unary)
    features = max(features, [], 3);
end