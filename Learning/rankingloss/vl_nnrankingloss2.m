
function Y = vl_nnrankingloss2(X,c,dzdy)
    
    inputSize = [size(X,1) size(X,2) size(X,3) size(X,4)] ;

    % Form 1: C has one label per image. In this case, get C in form 2 or
    % form 3.
    c = gather(c) ;
    if numel(c) == inputSize(4)
      c = reshape(c, [1 1 1 inputSize(4)]) ;
      c = repmat(c, inputSize(1:2)) ;
    end

    % --------------------------------------------------------------------
    % Do the work
    % --------------------------------------------------------------------

    % compute ranking loss
    sunsort = squeeze(X)';
    Delta = squeeze(c);
    [s,p] = sort(sunsort);
    slackmargin = 's';
    [psi,delta] = SORcomplete_mex(sunsort, s, p, Delta, slackmargin);
    
    if nargin <= 2 || isempty(dzdy)
        Y = delta;
    else
        Y = bsxfun(@times, dzdy, psi) ;
    end
end

