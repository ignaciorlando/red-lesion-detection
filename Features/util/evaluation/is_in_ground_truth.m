function it_is_in = is_in_ground_truth(current_candidate, gt_mas)

    % by default, the MA is not in the region
    it_is_in = 0;

    % iterate for each of the MAs in the ground truth
    for j = 1 : length(gt_mas.PixelIdxList)
        % check if current MA overlaps the j-th MA in the ground truth
        if ~isempty(intersect(current_candidate, gt_mas.PixelIdxList{j}))
            it_is_in = j;
            break
        end
    end
    
end