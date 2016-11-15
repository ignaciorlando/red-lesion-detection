function [w,costs] = ksupLogisticRegression(X,Y,lambda,k,w0, ...
                                        iters_acc,eps_acc);
% Author: Matthew Blaschko - matthew.blaschko@inria.fr
% Copyright (c) 2012-2013
%
% Run Ksupport norm using logistic loss function
% first 3 arguments are required!
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% If you use this software in your research, please cite:
%
% M. B. Blaschko, A Note on k-support Norm Regularized Risk Minimization.
% arXiv:1303.6390, 2013.
%
% Argyriou, A., Foygel, R., Srebro, N.: Sparse prediction with the k-support
% norm. NIPS. pp. 1466-1474 (2012)


    if(~exist('eps_acc','var'))
        eps_acc = 1e-4;
    end

    if(~exist('iters_acc','var'))
        iters_acc = 2000; 
    end
    
    
    if(~exist('w0','var'))
        w0 = zeros(size(X,2),1);
    end
    
    if(~exist('k','var'))
        k = round(size(X,2)/4);
    end
           
    if(size(X,1)>size(X,2)) % lipschitz constant for gradient
        L = eigs(X'*X,1)/4;
    else
        L = eigs(X*X',1)/4;
    end
    [w,costs] = overlap_nest(@(w)(LogisticLoss(w,X,Y)),...
                             @(w)(gradLogisticLoss(w,X,Y)), lambda, ...
                             L, w0, k, iters_acc,eps_acc);
end

function l = LogisticLoss(w,X,Y)
l = sum(log(1+exp(-Y.*(X*w))));
end

function g = gradLogisticLoss(w,X,Y)
g = -X'*(Y./(1.0+exp(Y.*(X*w))));
end

% end of file
