function ma_color = compare_results_using_models(I, binary_masks)

    % Show the image
    imshow(I);
    
    % Initialize a matrix of consensus
    consensus = zeros(size(I,1), size(I,2), length(binary_masks));
    
    % For each binary mask
    for i = 1 : length(binary_masks)
        % Assign to current slide in consensus
        consensus(:,:,i) = binary_masks{i} > 0;
    end
    % retrieve a mask with the agreement between different samples
    consensus = sum(consensus, 3)==length(binary_masks);
    
    % initialize the array of labels
    red_lesion_labels = cell(length(binary_masks) + 1, 1);
    
    % now remove consensus labels from each mask
    for i = 1 : length(binary_masks)
        % get current mask
        current_mask = binary_masks{i};
        % remove consensus labels from this mask
        current_mask(consensus>0) = false;
        % assign to red lesions
        red_lesion_labels{i} = current_mask;
    end
    red_lesion_labels{3} = consensus;

    % for each lesion label
    for j = 1 : length(red_lesion_labels)

        hold on
        
        % retrieve current segmentation
        ma_segmentation = red_lesion_labels{j};
        
        % Retrieve each centroid
        properties = regionprops(ma_segmentation>0, 'centroid', 'MajorAxisLength', 'MinorAxisLength','PixelIdxList');

        % for each lesion
        for i = 1 : length(properties)

            x = round(properties(i).Centroid(1));
            y = round(properties(i).Centroid(2));
            r = round(properties(i).MajorAxisLength + 2);
            th = 0:pi/50:2*pi;
            xunit = r * cos(th) + x;
            yunit = r * sin(th) + y;

            switch j
                case 1
                    h1 = plot(xunit, yunit, '-g', 'LineWidth', 2);                    
                case 2
                    h2 = plot(xunit, yunit, '-c', 'LineWidth', 2);    
                case 3
                    h3 = plot(xunit, yunit, '-r', 'LineWidth', 2);
            end

        end
        hold off

    end
    
    ma_color = frame2im(getframe(gcf)); 
        
    legend([h1, h2, h3], {'RF trained with hand crafted features', 'CNN probabilities', 'Match between methods'});

end