
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
    % Padd the image with zeros to recover MA candidates windows
    I_padded = padarray(I, [ceil(window_size/2) ceil(window_size/2)]);
    % Get ma candidates
    conn = bwconncomp(ma_candidates);
    % Initialize windows mask matrix (only for visualization purposes)
    windows_masks = zeros(size(I_padded, 1), size(I_padded, 2));
    
    % initialize list of windows
    ma_windows = uint8(zeros(window_size, window_size, 3, conn.NumObjects));
    % initialize array of pixel coordinates
    candidate_coordinates = cell(conn.NumObjects, 1);
    % identify centroids
    stats = regionprops(ma_candidates, 'Centroid', 'PixelIdxList');
    
    % for each of the candidates, take a window centered on the MA
    for i = 1 : conn.NumObjects
        
        center = round(stats(i).Centroid) + window_size/2;
            
        % concatenate the new window
        ma_windows(:,:,:,i) = I_padded(center(2) - window_size/2 : center(2) + window_size/2 - 1, ...
                                       center(1) - window_size/2 : center(1) + window_size/2 - 1, ...
                                       :);
        windows_masks(center(2) - window_size/2 : center(2) + window_size/2 - 1, ...
                      center(1) - window_size/2 : center(1) + window_size/2 - 1) = 1;
        % add the pixel coordinates to the cell array
        candidate_coordinates{i} = conn.PixelIdxList{i};
        
    end
    
    % show figure
    if (show_fig)
        figure, imshow(uint8(I_padded));
        alphamask(windows_masks, [0 0 1], 0.15);
    end
    
end