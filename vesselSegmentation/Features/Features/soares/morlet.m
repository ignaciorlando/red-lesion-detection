function out = morlet(dims, theta, a, epsilon, k0)
% function out = newmorlet(dims, theta, a, epsilon, k0)
%
% Implements the Morlet wavelet based on Antoine's paper in Physicalia
% Magazine on 2D wavelets. Inverse mapping of the parameters. "dims"
% is the size of the wavelet space, "a" is the scale, "epsilon" the
% elongation, and "k0" a vector with the horizontal and vertical
% frequencies.
%
% See also: maxmorlet.

%
% Copyright (C) 2003  Jorge de Jesus Gomes Leandro & 
%                     Roberto Marcondes Cesar Junior
%               2006  João Vitor Baldini Soares
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

lins = dims(1);
cols = dims(2);

% X values
x = (0:(cols - 1)) - (cols - 1)/2;
x = ones(lins,1) * x;

% Y values
y = (0:(lins - 1))' - (lins - 1)/2;
y = - y * ones(1,cols);

% Rotation by -theta
rotx = x * cos(-theta) - y * sin(-theta);
roty = x * sin(-theta) + y * cos(-theta);

%figure; mesh(rotx);title('x');
%figure; mesh(roty);title('y');

% Scaling: 1/a

scaledrotx = rotx / a;
scaledroty = roty / a;

% The complex exponential.
comp_exp = exp( j * (k0(1) * scaledrotx + k0(2) * scaledroty));

% A = [epsilon^(-0.5) 0; 0 1] only corrects x.
elongatedscaledrotx = scaledrotx * (epsilon^(-0.5));

% The gaussian.
gaussian2d = exp( (-0.5) * (elongatedscaledrotx.^2 + scaledroty.^2));

out = comp_exp .* gaussian2d;
