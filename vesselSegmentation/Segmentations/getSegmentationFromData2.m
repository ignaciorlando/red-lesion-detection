
function [segmentation, qualityMeasures] = getSegmentationFromData2(config, mask, y, X, pairwiseKernels, model)
% getSegmentationFromData2 Segment a given image
% [segmentation, qualityMeasures] = getSegmentationFromData2(config, mask, y, X, pairwiseKernels, model)
% OUTPUT: segmentation: resulting segmentation
%         qualityMeasures: a struct containing all the quality measures
% INPUT: config: configuration structure
%        mask: FOV mask
%        y: ground truth labelling
%        X: unary features
%        pairwiseKernels: pairwise kernels
%        model: learned model

    tic;

    % Get the unary potentials for each class
    background = double(mask);
    foreground = double(mask);
    
    % Get individual weights
    [W_unary, W_pairwises, W_bias] = getWeights(model.w, config);
    
    % Compute unary potentials
    background(mask==1) = -(W_unary(1, :) * X' + W_bias(1) * config.biasMultiplier)'; % background
    foreground(mask==1) = -(W_unary(2, :) * X' + W_bias(2) * config.biasMultiplier)'; % foreground
    
    background(mask==0) = min(background(logical(mask)));
    foreground(mask==0) = max(foreground(logical(mask)));

    unaryPotentials(:,:,1) = background;
    unaryPotentials(:,:,2) = foreground;
    
    % Compute pairwise potentials
    newPairwises = zeros(size(mask, 1), size(mask, 2), size(pairwiseKernels,2));
    for j = 1:size(newPairwises,3)
        p = single(mask);
        p(p==1) = pairwiseKernels(:,j);
        newPairwises(:,:,j) = p;
    end
    
    % Segment the image
    segmentation = CRFInference(config, unaryPotentials, mask, newPairwises, W_pairwises);
    segmentation = segmentation .* mask;

    % If there are labels
    if (y ~= Inf)
    
        % Compute quality measures
        yhat = segmentation(mask);
        qualityMeasures = getQualityMeasures(yhat, y(mask));

        % compute ROC curve
        if (config.compute_scores)

            % Prepare data for evaluation
            XX = cell(0);
            XX{2} = mask;
            yy = y * 2 - 1;

            % In case unary potentials are selected
            if (strcmp(config.experiment,'up'))

                % using only the unary scores
                qualityMeasures.unaryPotentials = - unaryPotentials(:,:,2);
                qualityMeasures.unaryPotentials = qualityMeasures.unaryPotentials(logical(mask));
                % roc curve
                [~,~,info] = vl_roc(double(yy(logical(mask))), double(qualityMeasures.unaryPotentials));
                qualityMeasures.aucUP = info.auc;
                % precision/recall
                [~,~,info] = vl_pr(double(yy(logical(mask))), double(qualityMeasures.unaryPotentials));
                qualityMeasures.aucUP_pr = info.auc;

                % using both the unary and the pairwise potentials
                qualityMeasures.scores = [];
                qualityMeasures.auc = [];
                qualityMeasures.auc_pr = [];

            else

                % compute the unary potentials
                XX{4} = newPairwises;
                pp = pairwisePotentials(config, XX, segmentation);
                for k = 1 : size(pp, 3)
                    pp(:,:,k) = W_pairwises(k) * pp(:,:,k);
                end
                qualityMeasures.scores = - (unaryPotentials(:,:,2) + sum(pp,3));
                qualityMeasures.scores = qualityMeasures.scores(logical(mask));

                % using only the unary scores
                qualityMeasures.unaryPotentials = [];
                qualityMeasures.aucUP = [];
                qualityMeasures.aucUP_pr = [];

                % using both the unary and the pairwise potentials
                [~,~,info] = vl_roc(double(yy(logical(mask))), double(qualityMeasures.scores));
                qualityMeasures.auc = info.auc;
                [~,~,info] = vl_pr(double(yy(logical(mask))), double(qualityMeasures.scores));
                qualityMeasures.auc_pr = info.auc;

            end

        else

            qualityMeasures.scores = [];
            qualityMeasures.auc = [];
            qualityMeasures.auc_pr = [];
            qualityMeasures.unaryPotentials = [];
            qualityMeasures.aucUP = [];
            qualityMeasures.aucUP_pr = [];

        end
        
    end
    
    qualityMeasures.time = toc;

end