function g = gaussian(stdx,stdy,theta,dim,centre,X,Y)

if ~isempty(centre)
    r1 = centre(1) - 1;
    r2 = dim(1) - centre(1);
    c1 = centre(2)-1;
    c2 = dim(2) - centre(2);
else
    r1 = round(dim(1)-1)/2;
    r2 = r1;
    c1 = round(dim(2)-1)/2;
    c2 = c1;
end

x0 = 0; y0 = 0;
 
sigma_x = stdx;
sigma_y = stdy;

A = 1;
% A = 1/(2*pi*sigma_x *sigma_y);

a = cos(theta)^2/2/sigma_x^2 + sin(theta)^2/2/sigma_y^2;
b = -sin(2*theta)/4/sigma_x^2 + sin(2*theta)/4/sigma_y^2 ;
c = sin(theta)^2/2/sigma_x^2 + cos(theta)^2/2/sigma_y^2;
if nargin == 5
    [X, Y] = meshgrid(-c1:c2,-r1:r2);
end
g = A*exp( - (a*(X-x0).^2 + 2*b*(X-x0).*(Y-y0) + c*(Y-y0).^2)) ;
% g = g / length(find(g));
