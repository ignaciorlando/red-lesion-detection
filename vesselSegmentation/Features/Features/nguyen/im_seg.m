function segmentedimg = im_seg(img,mask,W,step)
% img: original color image
% mask: mask of FOV
% W: window size which is chosen as double of typical vessel width
% step: step size for increasing the line length

img = im2double(img);
mask = im2bw(mask);

img = 1-img(:,:,2);
img = fakepad(img,mask);

features = standardize(img,mask);
Ls = 1:step:W;
for j = 1:numel(Ls)
   L = Ls(j);  
   R = get_lineresponse(img,W,L); 
   R = standardize(R,mask);
   features = features+R;
   disp(['L = ',num2str(L),' finished!']);       
end     
segmentedimg = features/(1+numel(Ls));
t = 0.56;
segmentedimg = im2bw(segmentedimg,t);

end