
function Y = vl_nnclassbalancingsoftmaxloss(X,c,beta,gamma,dzdy)

    if nargin <= 4
        
        % retrieve softmax loss for negative and positive samples
        Y_neg = vl_nnsoftmaxloss(X(:,:,:,c==1), c(c==1));
        Y_pos = vl_nnsoftmaxloss(X(:,:,:,c==2), c(c==2));
        % compute the class balanced softmax loss by weighting each softmax
        % loss according to the distribution of negative and positive
        % samples on the training sets, and weighting the entire loss by
        % gamma
        Y = single( gamma * (beta * Y_pos + (1-beta) * Y_neg) );
        
    else
        
        % initialize the gradient
        Y = single(zeros(size(X)));
        % compute the gradient for both the positive and the negative
        % classes, weighting each of them by the beta proportion
        Y(:,:,:,c==1) = single((1-beta) * vl_nnsoftmaxloss(X(:,:,:,c==1), c(c==1), dzdy));
        Y(:,:,:,c==2) = single((beta) * vl_nnsoftmaxloss(X(:,:,:,c==2), c(c==2), dzdy));
        % and now scale the gradient by gamma too
        Y = gamma * Y;
        
    end

end
