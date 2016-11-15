function [az fp tp] = rocarea(fp, tp, p, n)
% az = rocarea(fp, tp, p, n)
%
% Gives the area under the ROC curve specified in the following
% manner:
%
% fp - vector of false positive counts
% tp - vector of true positive counts
%  p - total value of positives
%  n - total value of negatives
%
% Use "rocdata" to create these values from images.
%
% See also: rocdata.

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

fp = fp / n;
tp = tp / p;

fp = fp(end:-1:1);
tp = tp(end:-1:1);

% figure;plot(fp,tp,'linewidth',1);
% set(gca,'YGrid','off');
% set(gca,'XGrid','off');
% set(gca,'XTick',0:.1:1)
% set(gca,'XTickLabel',[0:.1:1])
%axis square;

if size(fp, 1) > 1
  az = 0;
  
  for i = 2:size(fp, 1)
    a = tp(i);
    b = tp(i-1);
    h = fp(i) - fp(i-1);
    
    area = (a + b) * h / 2;
    az = az + area;
  end
else
  az = -1;
end
