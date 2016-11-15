% copyright 2012 Andreas Argyriou
% GPL License http://www.gnu.org/copyleft/gpl.html

function [ q , p, r, l] = prox_overlap( v, k, L)

% Compute prox_f(v) for f = 1/(2L) ||.||^2 
% and ||.|| the k overlap norm

d = length(v);
[beta, order] = sort(abs(v), 'descend');
beta = beta * L;
beta(d+1) = -inf;

found = false;
for l=k:d
  temp = sum(beta(k:l));        
  for r=0:k-2
    if ( (temp >= (l-k+(L+1)*r+L+1)*beta(k-r)/(L+1)) && ...
   (temp < (l-k+(L+1)*r+L+1)*beta(k-r-1)/(L+1)) && ...
	 (temp >= (l-k+(L+1)*r+L+1)*beta(l+1)) && ...
	 (temp < (l-k+(L+1)*r+L+1)*beta(l)) )
      found = true;
      break;
    else
      temp = temp + beta(k-r-1);
    end
  end
  if (~found)
    r = k-1;
    if ( (temp >= (l-k+(L+1)*r+L+1)*beta(k-r)/(L+1)) && ...
	 (temp >= (l-k+(L+1)*r+L+1)*beta(l+1)) && ...
	 (temp < (l-k+(L+1)*r+L+1)*beta(l)) )
      found = true;
      break;
    end
  else
    break;
  end
end

p(1:k-r-1) = beta(1:k-r-1)/(L+1);
p(k-r:l) = temp / (l-k+(L+1)*r+L+1);
p(l+1:d) = beta(l+1:d);
p = p';

[dummy, rev]=sort(order,'ascend');
p = sign(v) .* p(rev);
q = v - 1/L*p;

end
