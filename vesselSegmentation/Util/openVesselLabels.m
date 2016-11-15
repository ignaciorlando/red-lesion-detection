function [labels] = openVesselLabels(folder)

    disp(strcat('Loading labels from ', [' '], folder));

    % Open images, masks and labels
    disp('Loading labels');
    labels = openMultipleImages(folder);
    
    % For each image
    for i = 1:length(labels)
        % Encode labels as logical matrices
        y = labels{i};
        labels{i} = y(:,:,1) > 0;
    end
    
    fprintf('\n');
    disp('Loading finished');

end
