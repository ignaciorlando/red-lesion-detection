% copyright 2012 Andreas Argyriou
% GPL License http://www.gnu.org/copyleft/gpl.html

function [ normw , alpha ] = norm_overlap( w, k )

% Compute k overlap norm
% alpha is a subgradient

d = length(w);
[beta, ind] = sort(abs(w), 'descend');

s = sum(beta(k:d));
temp = s;
found = false;
for r=0:k-2
  if ( (temp >= (r+1)*beta(k-r)) && (temp < (r+1)*beta(k-r-1)) )
    found = true;
    break;
  else
    temp = temp + beta(k-r-1);
  end
end
if (~found)
  r=k-1;
end

alpha(1:k-r-1) = beta(1:k-r-1);
alpha(k-r:d) = temp / (r+1);
alpha = alpha';
[dummy,rev]=sort(ind,'ascend');
alpha = sign(w) .* alpha(rev);

normw = sqrt( beta(1:k-r-1)'*beta(1:k-r-1) + temp^2/(r+1) );

end
