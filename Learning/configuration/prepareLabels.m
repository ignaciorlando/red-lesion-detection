
function [labels] = prepareLabels(labels, options)
  
    if (strcmp(options.typeProblem,'dr-detection'))
        
        % If it is a dr detection problem, then all the labels
        % corresponding to different types of dr will be set to 1 and
        % healthy patients will be 0.
        labels = double(labels > 0);
        % Rearrange the labels so -1 represents the negative class and +1
        % represents the positive one
        labels = 2 * labels - 1;
        
    elseif (strcmp(options.typeProblem,'pdr-detection'))
        
        labels = double(labels==3);
        labels = 2 * labels - 1;
        
        
    elseif (strcmp(options.typeProblem,'dr-grading') || strcmp(options.typeProblem, 'multinomial-dr'))
        
        % preserve all the labels as they are
        labels = labels +1;
        
    elseif (strcmp(options.typeProblem,'one-vs-all'))
        
        labels = double(labels==options.one_label);
        labels = 2 * labels - 1;
        
    elseif (strcmp(options.typeProblem,'need-to-referral'))
        
        labels = 2 * (labels > 1) - 1;
        %labels = (labels > 0)+1;
        
    end
    
end