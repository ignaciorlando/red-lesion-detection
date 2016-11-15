
function qualityArias = computeAriasQualityMeasure(Sg, S, alpha, beta)

    % Sg = reference image, gold standard segmentation
    % S = segmentation to evaluate
    
    Sg = logical(Sg);
    S = logical(S);
    if (nargin < 3)
        alpha = 2;
        beta = 2;
    end
    
    
    % ********************************************
    % Connectivity (C)
    
    % Number of connected components on Sg
    stcon = bwconncomp(Sg);  
    Sg_numConnectedComponents = stcon.NumObjects;
    % Number of connected components 
    stcon = bwconncomp(S);
    S_numConnectedComponents = stcon.NumObjects;
    
    % C(S,Sg)
    qualityArias.C = 1 - min(1, abs(Sg_numConnectedComponents - S_numConnectedComponents) / length(find(Sg)));
    
    
    % ********************************************
    % Area (A): Jaccard Coefficient
    
    deltaS = imdilate(S, strel('disk',alpha,0));
    deltaSg = imdilate(Sg, strel('disk',alpha,0));
    
    qualityArias.A = length(find((deltaS .* Sg) + (S .* deltaSg))) / length(find(S + Sg));
    
    
    % ********************************************
    % Length (L)
    
    deltaS = imdilate(S, strel('disk',beta,8));
    deltaSg = imdilate(Sg, strel('disk',beta,8));
    phiS = bwmorph(S, 'skel', Inf);
    phiSg = bwmorph(Sg, 'skel', Inf);
    
    qualityArias.L = length(find((phiS .* deltaSg) + (deltaS .* phiSg))) / length(find(phiS + phiSg));
    
    
    % ********************************************
    % CAL measure
    
    qualityArias.cal = qualityArias.C * qualityArias.A * qualityArias.L;

end