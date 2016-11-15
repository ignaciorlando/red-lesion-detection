
function [fpi, per_lesion_sensitivity, froc_score, reference_se_vals] = froc(scores_maps, gt_labels, show_fig)

    if exist('show_fig','var')==0
        show_fig = true;
    end

    % Sort the scores
    try
        all_scores = cell2mat(scores_maps);
    catch 
        all_scores = [];
        for i = 1 : length(scores_maps)
            current_scores = scores_maps{i};
            all_scores = cat(1, all_scores, unique(current_scores(:)));
        end
    end
    thresholds = sort(unique(all_scores(:)));
    clear all_scores

    if (length(thresholds) > 1)
        
        % initialize matrices with tp lesions, n lesions and fp candidates
        tps_lesions = zeros(length(scores_maps), length(thresholds));
        ns_lesions = zeros(length(scores_maps), 1);
        fps_candidates = zeros(length(scores_maps), length(thresholds));
        
        fprintf('Computing FROC curve\n');
        % for each score map
        for j = 1 : length(scores_maps)
            fprintf('.');
            current_score = scores_maps{j};
            ground_truth = gt_labels{j} > 0;
            % label each connected region in the ground truth and count the
            % number of lesions
            [ground_truth_labeled, ns_lesions(j)] = bwlabel(ground_truth); 
            
            % for each threshold value
            parfor i = 1 : length(thresholds)
                % segment using the given threshold
                current_segmentation = current_score > thresholds(i);
                % analyze intersection between score map and ground truth
                true_intersection = logical(current_segmentation .* ground_truth);
                % tp lesions will be all the lesions that were detected
                tps_lesions(j,i) = length(unique(ground_truth_labeled(true_intersection)));
                % fp will be all the candidates that are not inside a red
                % lesion region
                [candidates_labeled, n_candidates] = bwlabel(current_segmentation);
                fps_candidates(j,i) = n_candidates - length(unique(candidates_labeled(true_intersection)));
            end
        end
        fprintf('\n');
        
        % per lesion sensitivity
        per_lesion_sensitivity = sum(tps_lesions, 1) / sum(ns_lesions);
        % false positives per image
        fpi = mean(fps_candidates, 1);

        % FPI references according to Niemeijer et al., TMI 2009
        fpi_references = [1/8, 1/4, 1/2, 1, 2, 4, 8];

        % sort FPI and per lesion sensitivities
        [sorted_fpi, idxs] = sort(fpi);
        sorted_per_lesion_sensitivity = per_lesion_sensitivity(idxs);
        % retrieve unique FPIs
        [u_sorted_fpi,index] = unique(sorted_fpi,'first');
        u_sorted_per_lesion_sensitivity = sorted_per_lesion_sensitivity(index);
        
        
        non_zero_idxs = (u_sorted_fpi~=0);
        u_sorted_fpi = u_sorted_fpi(non_zero_idxs);
        u_sorted_per_lesion_sensitivity = u_sorted_per_lesion_sensitivity(non_zero_idxs);
        
        values_to_complete = fpi_references(logical(ones(1, length(fpi_references)) - (min(u_sorted_fpi) < fpi_references)));
        u_sorted_fpi = cat(2, values_to_complete, u_sorted_fpi); 
        u_sorted_per_lesion_sensitivity = cat(2, zeros(size(values_to_complete)), u_sorted_per_lesion_sensitivity);
        
        
        % interpolate values
        reference_se_vals = interp1(u_sorted_fpi, u_sorted_per_lesion_sensitivity, fpi_references, 'spline') ;
        reference_se_vals(reference_se_vals<0) = 0;
        
        % Now, take the mean of those values as the FROC score
        froc_score = mean(reference_se_vals);

        % if show_fig, show the plot
        if (show_fig)
            plot_froc(per_lesion_sensitivity, fpi);
        end
        
    else
        
        fpi = [];
        per_lesion_sensitivity = [];
        froc_score = 0;
        
    end

end

