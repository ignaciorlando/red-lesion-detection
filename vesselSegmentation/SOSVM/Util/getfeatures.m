
function [phi] = getfeatures(x, y)

    % Get the feature vectors
    X = x{3};
    
    % Compute the unary features
    phi_u = zeros(size(X, 1), size(X, 2) * 2);
    
    % Take the Kronecker product of the features with the corresponding
    % binary vector, according to the given labeling y
    phi_u(y==0, :) = kron(X(y==0, :), [1 0]);
    phi_u(y==1, :) = kron(X(y==1, :), [0 1]);
    
    % Return the unary features
    phi = phi_u;
    
end
