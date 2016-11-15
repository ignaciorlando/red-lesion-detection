function linemask = get_linemask(theta,masksize)
% (theta,masksize)
% Create a mask for line with angle theta
if theta > 90
   mask = getbasemask(180- theta,masksize);
   linemask = rotatex(mask);
else
   linemask = getbasemask(theta,masksize);
end
% imshow(linemask,'InitialMagnification','fit');
end

function rotatedmask = rotatex(mask)
[h,w] = size(mask);
rotatedmask = zeros(h,w);

for i = 1:h
    for j = 1:w
        rotatedmask(i,j) = mask(i,w-j+1);
    end
end
end

function mask = getbasemask(theta,masksize)

mask = zeros(masksize);

halfsize = (masksize-1)/2;

if theta == 0
    mask(halfsize+1,:) = 1;
elseif theta == 90
    mask(:,halfsize+1) = 1;
else
    x0 = -halfsize;
    y0 = round(x0*(sind(theta)/cosd(theta)));

    if y0 < -halfsize
        y0 = -halfsize;
        x0 = round(y0*(cosd(theta)/sind(theta)));
    end

    x1 = halfsize;
    y1 = round(x1*(sind(theta)/cosd(theta)));

    if y1 > halfsize
        y1 = halfsize;
        x1 = round(y1*(cosd(theta)/sind(theta)));
    end

    pt0 = [halfsize-y0+1 halfsize+x0+1];
    pt1 = [halfsize-y1+1 halfsize+x1+1];

    mask = drawline(pt0,pt1,mask);
end

end

function img = drawline(pt0,pt1,orgimg)
img = orgimg;
linepts = getlinepts(pt0,pt1);
for i = 1:size(linepts,1)
   img(linepts(i,1),linepts(i,2)) = 1; 
end

end

function [linepts] = getlinepts(pt0,pt1)
% Return the points along the straight line connecting pt1 and pt2
if pt0(2) < pt1(2)
    x0 = pt0(2);    y0 = pt0(1);
    x1 = pt1(2);    y1 = pt1(1);
else
    x0 = pt1(2);    y0 = pt1(1);
    x1 = pt0(2);    y1 = pt0(1);
end

dx = x1 - x0;   dy = y1 - y0;
ind = 1;
linepts = zeros(numel(x0:x1),2);
step = 1;
if dx == 0 
   x = x0;
   if dy < 0,   step = -1;  end
   for y = y0:step:y1
        linepts(ind,:) = [y,x];
        ind = ind + 1;
   end
elseif abs(dy) > abs(dx)
    if dy < 0,  step = -1;  end
    for y = y0:step:y1
       x = round((dx/dy)*(y - y0) + x0);
       linepts(ind,:) = [y,x];
       ind = ind + 1;
    end
else
    for x = x0:x1
        y = round((dy/dx)*(x - x0) + y0);
        linepts(ind,:) = [y, x]; 
        ind = ind + 1;
    end
end

end