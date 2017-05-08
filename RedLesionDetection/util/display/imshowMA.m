
function ma_color = imshowMA(I, ma, method)

    if (strcmp(method, 'color'))

        % If the image is not in color, generate a gray scale image
        if (size(I,3)==1)
            I = cat(3, I, I, I);
        end
        ma_color = im2double(I);
        
        % For each color band
        for i = 1 : size(ma_color,3)
            % Reproduce all the intensities in the original image, but in the
            % green band set the MA to be green
            I_sub = ma_color(:,:,i);
            if (i==2)
                I_sub(ma>0) = 1;
            else
                I_sub(ma>0) = 0;
            end
            ma_color(:,:,i) = I_sub;
        end

        if (length(unique(ma)) > 2)
            
            only_green_band = ma_color(:,:,2);
            conn_comp = bwconncomp(ma>0);
            for i = 1 : conn_comp.NumObjects
                only_green_band(conn_comp.PixelIdxList{i}) = unique(ma(conn_comp.PixelIdxList{i}));
            end
            ma_color(:,:,2) = only_green_band;
            
        end
        
        % Show image
        imshow(ma_color);
        
    elseif (strcmp(method, 'circles'))
        
        % Retrieve each centroid
        properties = regionprops(ma>0, 'centroid', 'MajorAxisLength', 'MinorAxisLength');
        
        % Show the image
        imshow(I);
        hold on
        for i = 1 : length(properties)
            
            x = round(properties(i).Centroid(1));
            y = round(properties(i).Centroid(2));
            r = round(properties(i).MajorAxisLength + 0.5 * properties(i).MajorAxisLength);
            th = 0:pi/50:2*pi;
            xunit = r * cos(th) + x;
            yunit = r * sin(th) + y;
            if exist('color','var') == 0
                color = [0 1 0];
            end
            plot(xunit, yunit, 'Color', color, 'LineWidth', 1);
            
        end
        hold off
        
        ma_color = frame2im(getframe(gcf)); 
        
    end
        

end