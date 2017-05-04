function our_figure = imshow_red_lesion_prob(I, probability_map, color)

    if exist('color','var')==0
        color = [0 0 1];
    end

    % Retrieve each centroid
    properties = regionprops(probability_map > 0, 'centroid', 'PixelIdxList');
    
    % Show the image
    figure, imshow(I);
    hold on
    for i = 1 : length(properties)

        % create a binary mask with only the current lesion
        bw_mask = false(size(I,1), size(I,2));
        bw_mask(properties(i).PixelIdxList) = true;
        
        % retrieve probability
        current_probabilities = unique(probability_map(properties(i).PixelIdxList));
        
        % now incorporate it to current figure
        alphamask(bw_mask, color, current_probabilities(1), gca);
            
    end
    
    hold off

    our_figure = frame2im(getframe(gcf)); 

end