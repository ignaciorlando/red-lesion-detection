function E = blurshift(A,sigma,shiftrow,shiftcol,minRC,maxRC)

if nargin == 4
    minRC = [1 1];
    maxRC = [size(A,1),size(A,2)];
end
E = maxgaussianfilter(A,sigma,shiftrow,shiftcol,minRC,maxRC);

function D = maxgaussianfilter(A,sigma,shiftrow,shiftcol,minRC,maxRC)

[rA,cA] = size(A);
D = zeros([rA,cA]);
radius = round(sigma * 3.5);
gauss1D = exp(-[-radius:radius].^2./(2*sigma*sigma));

[Brows Bcols] = find(A);
start = min([Brows Bcols],[],1);
stop = max([Brows Bcols],[],1);    
xrange = truncateNegIndex([start(2)-radius:stop(2)+radius]-shiftcol,cA);
yrange = truncateNegIndex([start(1)-radius:stop(1)+radius]-shiftrow,rA);        

xroiarea = minRC(2):maxRC(2);
yroiarea = minRC(1):maxRC(1);
f1 = find(ismember(xrange,xroiarea));
f2 = find(ismember(yrange,yroiarea));
xrange = xrange(f1);
yrange = yrange(f2);

xrange1 = start(2)-radius:stop(2)+radius;   
yrange1 = start(1)-radius:stop(1)+radius;
xroiarea2 = xroiarea + shiftcol;
yroiarea2 = yroiarea + shiftrow;
f1 = find(ismember(xrange1,xroiarea2));
f2 = find(ismember(yrange1,yroiarea2));
xrange2 = truncateNegIndex([start(2)-radius:stop(2)+radius],cA);
yrange2 = truncateNegIndex([start(1)-radius:stop(1)+radius],rA);        
Z1 = zeros(length(yrange1),length(xrange1));
rowFrom = abs(yrange1(1) - yrange2(1)) + 1;
colFrom = abs(xrange1(1) - xrange2(1)) + 1;
Z1(rowFrom:rowFrom+length(yrange2)-1,colFrom:colFrom+length(xrange2)-1) = A(yrange2,xrange2);

if ~isempty(f1) && ~isempty(f2)
    if length(f1) < length(f2)
        Z = dilate(dilate(Z1,gauss1D,f1(1)-1,f1(end),f2(1)-1,f2(end)),gauss1D',f1(1)-1,f1(end),f2(1)-1,f2(end));
    else
        Z = dilate(dilate(Z1,gauss1D',f1(1)-1,f1(end),f2(1)-1,f2(end)),gauss1D,f1(1)-1,f1(end),f2(1)-1,f2(end));
    end
    D(yrange,xrange) = Z(f2,f1);
end

function [area mn mx] = getConnArea(bw,nconn,radius)

area = 0;
for i = 1:nconn
    [r c] = find(bw == i);
    mn(i,:) = min([r c],[],1);
    mx(i,:) = max([r c],[],1);
    area = area + ((mx(i,1)-mn(i,1)+1+radius+radius) * (mx(i,2)-mn(i,2)+1+radius+radius));
end

function posindex = truncateNegIndex(indexrange,mx)

posindex = indexrange(find(indexrange>0 & indexrange <= mx));