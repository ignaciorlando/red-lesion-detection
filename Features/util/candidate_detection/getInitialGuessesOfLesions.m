
function [candidates] = getInitialGuessesOfLesions(I, fov_mask, l, K)

    % get the tophat transformation
    tophat = getTopHatTransformation(I, l) .* double(fov_mask);
    tophat(imcomplement(fov_mask)) = 0;
    
    % thresholding
    T_l = 0.05; T_u = 0.2; 
    increment = -0.002;
    ts = max(tophat(:)):increment:min(tophat(:));   
    max_num_conn_comp = -Inf;
    
    t = 1;
    % for each threshold, check how many connected components remain... if
    % the number is higher, continue searching...
    while (max_num_conn_comp < K) && (t <= length(ts))
        CC = bwconncomp(tophat > ts(t));        
        max_num_conn_comp = CC.NumObjects;
        t = t + 1;
    end
    
    if (t==2) % if any value ensures more than K values
        T_k = T_l;
    elseif (max_num_conn_comp >= K) % if the value ensure less than K values
        T_k = ts(t-1);
    else % if any value ensures less than K values
        T_k = T_u;
    end

    % get the candidates
    candidates = tophat > T_k;

end