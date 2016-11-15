
function [delta] = lossCB(param, y, tildey)
% lossCB Compute the loss
% [delta] = lossCB(param, y, tildey)
% OUTPUT: delta: loss
% INPUT: param: parameters
%        y: ground truth labelling
%        tildey: estimated labelling

    delta = length(find(y~=tildey));
    
end