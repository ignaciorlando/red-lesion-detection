function wtmodmax = maxmorlet(fimg, a, epsilon, k0, step)
% wtmodmax = maxmorlet(fimg, a, epsilon, k0, step)
%
% Calculates the maximum modulus morlet wavelet response over all
% angles. "fimg" is the fft2 transform of the original image, "a" is
% the scale, "k0" is a vector with the horizontal and vertical
% frequencies, and step is the incremental step for the angle (in
% degrees).
%
% See also: morlet.

%
% Copyright (C) 2003  Jorge de Jesus Gomes Leandro
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

[lins, cols] = size(fimg);

% largelins and largecols are used so that the convolution fits
% exactly to the original image.
largelins = lins + 1 + mod(lins, 2);
largecols = cols + 1 + mod(cols, 2);

% Isso está errado quando só tem a parte real.
wtmodmax = - Inf * ones(lins,cols);

for t = 0:step:179

  % Transfers angle to rad.
  theta= t * (pi/180);
  
  % Calculates wavelet in space domain
  wvlt = morlet([largelins largecols], theta, a, epsilon, k0);
  wvlt = wvlt(1:lins, 1:cols);

  % Takes the complex conjugate.
  cwvlt = conj(wvlt);
  
  % Shifts.
  cwvlt = fftshift (cwvlt);

  % Transfers to the frequency domain.
  fcwvlt = fft2 (cwvlt);

  % Multiplies image by wavelet conjugate in frequency domain.  The
  % conjugate below indicates correlation in space, instead of
  % convolution.
  fimgwv = fimg .* conj (fcwvlt);

  % Back to space domain.
  imgwv = ifft2 (fimgwv);

  % Normalization (only by scale a)
  imgwv = imgwv / a;

  % Get the modulus of the result.
  modimgwv = abs (imgwv);
  
  % Updates the maximum.
  wtmodmax = max( modimgwv, wtmodmax );

end
