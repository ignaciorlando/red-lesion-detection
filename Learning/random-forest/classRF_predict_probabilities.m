
function [probabilities, y_hat] = classRF_predict_probabilities(features, model)

    % get predictions and votes (call to an external package)
    [y_hat, votes] = classRF_predict(features, model);
    
    % now output the probabilities
    probabilities = votes(:,2) ./ sum(votes, 2);
    
end