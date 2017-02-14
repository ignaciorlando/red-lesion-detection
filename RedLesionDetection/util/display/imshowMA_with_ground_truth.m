function ma_color = imshowMA_with_ground_truth(I, ma_ground_truth, ma_segmentation)

    % Retrieve each centroid
    properties = regionprops(ma_segmentation>0, 'centroid', 'MajorAxisLength', 'MinorAxisLength','PixelIdxList');

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
        
        if any(ma_ground_truth(properties(i).PixelIdxList) > 0)
            plot(xunit, yunit, '-g', 'LineWidth', 2);
        else
            plot(xunit, yunit, '-r', 'LineWidth', 2);
        end
            
    end
    hold off

    ma_color = frame2im(getframe(gcf)); 
        

end