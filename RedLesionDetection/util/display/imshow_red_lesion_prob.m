function our_figure = imshow_red_lesion_prob(I, probability_map, color)

    if exist('color','var')==0
        color = [0 0 1];
    end

    % Retrieve each centroid
    properties = regionprops(probability_map > 0, 'centroid', 'PixelIdxList');
    
    % Show the image
    figure, imshow(I);
    hold on
    
    % Check if all probabilities are the same
    if length(unique(probability_map(:))) > 2
        
        for i = 1 : length(properties)

            % create a binary mask with only the current lesion
            bw_mask = false(size(I,1), size(I,2));
            bw_mask(properties(i).PixelIdxList) = true;

            % retrieve probability
            current_probabilities = unique(probability_map(properties(i).PixelIdxList));

            % now incorporate it to current figure
            alphamask(bw_mask, color, current_probabilities(1), gca);

        end
        
    else
        
        current_probabilities = unique(probability_map(:));
        current_probabilities(current_probabilities == 0) = [];
        
        if (islogical(I))
            
            non_vessel = I .* probability_map;
            alphamask(non_vessel > 0, [1 0 0], current_probabilities, gca);
            
            on_vessel = imcomplement(segm_aux_2) .* probability_map;
            alphamask(on_vessel > 0, [0 1 0], current_probabilities, gca);
            
        else
            
            % now incorporate it to current figure
            alphamask(probability_map > 0, color, current_probabilities, gca);
            
        end
        
    end
    hold off

    if nargout > 0
        our_figure = frame2im(getframe(gcf)); 
    end

end