
function [ma_windows, candidate_coordinates] = maWindowsExtraction(ma_candidates, I, window_size, show_fig, mask)

    if (nargin < 3)
        window_size = 32;
        show_fig = false;
    end

    % -------------------------------------------------------
    % PREPARE DATA
    % -------------------------------------------------------   
    % Generate logical matrices
    ma_candidates = ma_candidates > 0;
    mask = mask > 0;
    % Preprocess the image
    [I] = contrastEqualization(I, mask);
    % Get ma candidates
    conn = bwconncomp(ma_candidates);
    
    % -------------
    % % Initialize windows mask matrix (only for visualization purposes)
    %windows_masks = zeros(size(I_padded, 1), size(I_padded, 2));
    % -------------
    
    % initialize list of windows
    ma_windows = uint8(zeros(window_size, window_size, 3, conn.NumObjects));
    % initialize array of pixel coordinates
    candidate_coordinates = cell(conn.NumObjects, 1);
    % identify centroids
    stats = regionprops(ma_candidates, 'Centroid', 'PixelIdxList','MajorAxisLength');
    
    % for each of the candidates, take a window centered on the MA
    for i = 1 : conn.NumObjects
        
        % If the major axis length * 2 is smaller than the window size...
        if (stats(i).MajorAxisLength * 2 < window_size)
            % This window will have a size equal to the default window size
            current_window_size = window_size;
        else
            % This window will have a size of 2 * its major axis length
            current_window_size = ceil(stats(i).MajorAxisLength) * 2;
        end
        
        % Localize the central coordinate of the lesion
        center = round(stats(i).Centroid) + current_window_size/2;

        % Padd the image with zeros to recover MA candidates windows
        I_padded = padarray(I, [ceil(current_window_size/2) ceil(current_window_size/2)]);

        % Retrieve current window
        current_window = I_padded(center(2) - current_window_size/2 : center(2) + current_window_size/2 - 1, ...
                                  center(1) - current_window_size/2 : center(1) + current_window_size/2 - 1, ...
                                  :);
        % --------------
        % %windows_masks(center(2) - current_window_size/2 : center(2) + current_window_size/2 - 1, ...
        %              center(1) - current_window_size/2 : center(1) + current_window_size/2 - 1) = 1;
        % --------------
        
        % If current_window_size is bigger than the default window size...
        if current_window_size > window_size
            % initialize the window
            my_resized_window = uint8(zeros(window_size, window_size, 3));
            % resize the window to the original resolution
            for cb = 1 : size(current_window, 3)
                my_resized_window(:,:,cb) = imresize(current_window(:,:,cb), [window_size window_size]);
            end
            current_window = my_resized_window;
        end
        % concatenate the new window
        ma_windows(:,:,:,i) = current_window;    
        
        % add the pixel coordinates to the cell array
        candidate_coordinates{i} = conn.PixelIdxList{i};
        
    end
    
    % show figure
    if (show_fig)
        figure, imshow(uint8(I_padded));
        alphamask(windows_masks, [0 0 1], 0.15);
    end
    
end