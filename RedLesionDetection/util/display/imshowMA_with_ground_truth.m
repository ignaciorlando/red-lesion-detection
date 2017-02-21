function ma_color = imshowMA_with_ground_truth(I, ma_ground_truth, ma_segmentation)

    % Retrieve each centroid
    properties = regionprops(ma_segmentation>0, 'centroid', 'MajorAxisLength', 'MinorAxisLength','PixelIdxList');
    properties_gt = regionprops(ma_ground_truth>0, 'centroid', 'MajorAxisLength', 'MinorAxisLength','PixelIdxList');
    
    % Show the image
    imshow(I);
    hold on
    for i = 1 : length(properties)

        x = round(properties(i).Centroid(1));
        y = round(properties(i).Centroid(2));
        r = round(properties(i).MajorAxisLength + 2);
        th = 0:pi/50:2*pi;
        xunit = r * cos(th) + x;
        yunit = r * sin(th) + y;
        
        found = false;
        
        for j = 1 : length(properties_gt)
            if any(ismember(properties(i).PixelIdxList, properties_gt(j).PixelIdxList))
                ma_ground_truth(properties_gt(j).PixelIdxList) = false;
                plot(xunit, yunit, '-g', 'LineWidth', 2);
                found = true;
                break
            end
        end
        
        if ~found
            plot(xunit, yunit, '-y', 'LineWidth', 2);
        end
            
    end
    
    % Retrieve each centroid
    properties_gt = regionprops(ma_ground_truth>0, 'centroid', 'MajorAxisLength', 'MinorAxisLength','PixelIdxList');
    for i = 1 : length(properties_gt)

        x = round(properties_gt(i).Centroid(1));
        y = round(properties_gt(i).Centroid(2));
        r = round(properties_gt(i).MajorAxisLength + 2);
        th = 0:pi/50:2*pi;
        xunit = r * cos(th) + x;
        yunit = r * sin(th) + y;
        
        plot(xunit, yunit, '-r', 'LineWidth', 2);
            
    end
    
    
    hold off

    ma_color = frame2im(getframe(gcf)); 
        

end