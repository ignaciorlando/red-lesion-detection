
function Y = vl_nnrankingloss(X,c,dzdy)

    c = c - 1;
%     X = [0;0;0;0;1];
%     c = [1;0;0;0;1];
%     X = [4;3.5;3];
%     c = [0;1;1];

    % Reduce dimensionality of the input matrix to a #classes x batch_size
    % matrix
    X_ = squeeze(X);
    if (size(X_,1) < size(X_,2))
        X_ = X_';
    end
    
    % Do the same for c, and subtract 1 so values are in [0 #classes-1]
    c = squeeze(c);
    if (size(c,1) < size(c,2))
        c = c';
    end

    % Compute penalties for label 1
    Delta = max(c) - c;
    Delta2 = Delta;
    
    % Sort scores
    sunsort = X_;
    [Delta, pDelta] = sort(Delta);
    sunsort = sunsort(pDelta); % added by Matthew 15/09/2016 11:45 Belgian time
    [~,invInd] = sort(pDelta);
    [s, p] = sort(sunsort);
    
    % Compute both the loss and the gradient
    [alpha, delta] = SORcomplete_mex(double(sunsort), double(s), double(p), double(Delta), 'm');
    psi = alpha(invInd);
    sunsort = sunsort(invInd);
    
    %constant = 1e-1;%1000;
    constant = 1;
    
    % generate output depending on the number of input arguments
    if nargin <= 2
        % if there is no gradient in the input, then use delta and psi to
        % compute the loss
        loss = delta - dot(sunsort,psi);
        Y = single(loss * constant) ;
    else
        % if there is a gradient, then reshape psi to have the same 
        % dimensions than X       
        Y = reshape(-psi, size(X)) * constant;
        % project this gradient into dzdy
        Y = single(bsxfun(@times, Y, dzdy)) ;
    end

end
