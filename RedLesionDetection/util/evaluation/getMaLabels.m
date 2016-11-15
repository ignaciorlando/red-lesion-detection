
function [ma_labels] = getMaLabels(labels, candidates_px)

    % initialize ma labels
    ma_labels = zeros(length(candidates_px),1);
    % for each candidate
    for i = 1 : length(candidates_px)
        
        % check if the intensity on labels is higher than one
        ma_labels(i) = any(labels(candidates_px{i})>0);
        
    end

end