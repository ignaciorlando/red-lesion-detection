
function mcc = calculateStatistics(tp, fn, tn, fp)

    % compute the matthew's correlation coefficient
    mcc = (tp*tn - fp*fn)/ sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn));
    
end



