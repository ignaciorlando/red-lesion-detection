function postprocessedimg = noisefiltering(segmentedimg,noisesize)
% Remove all disconnected noisy objects (small sizes) and keep only the vascular network

if nargin == 1, noisesize = 100;  end

postprocessedimg = zeros(size(segmentedimg));
[segmentedimg_lb,nobjs] = bwlabel(segmentedimg);
for i = 1:nobjs
   cur_obj = find(segmentedimg_lb == i);
   cur_size = numel(cur_obj);
   if cur_size > noisesize
      postprocessedimg(cur_obj) = 1;
   end
end

end