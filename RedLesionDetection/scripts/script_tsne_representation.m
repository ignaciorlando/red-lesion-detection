
config_tsne_representation;

% Load the CNN to add the average image
load(cnn_filename);
% Load the windows
windows = load(windows_filenames);

switch features
    case 'cnn'
        % Load the CNN features
        imdb_cnn = load(imdb_cnn_filename);
    case 'hand-crafted'
        % Load the hand crafted features
        imdb_hand_crafted = load(imdb_hand_crafted_filename);
    case 'all'
        % Load the CNN features
        imdb_cnn = load(imdb_cnn_filename);
        % Load the hand crafted features
        imdb_hand_crafted = load(imdb_hand_crafted_filename);
end

% Count the number of samples we have
number_of_samples = 0;
for i = 1 : length(imdb_cnn.imdb.images.data)
    switch features
        case 'cnn'
            number_of_samples = number_of_samples + size(imdb_cnn.imdb.images.data{i}, 1);
        case 'hand-crafted'
            number_of_samples = number_of_samples + size(imdb_hand_crafted.imdb.images.data{i}, 1);
        case 'all'
            number_of_samples = number_of_samples + size(imdb_cnn.imdb.images.data{i}, 1);
    end
end

% Prepare the design matrix, the labels and the array of windows
switch features
    case 'cnn'
        X = zeros(number_of_samples, size(imdb_cnn.imdb.images.data{i},2));
    case 'hand-crafted'
        X = zeros(number_of_samples, size(imdb_hand_crafted.imdb.images.data{i},2));
    case 'all'
        X = zeros(number_of_samples, size(imdb_cnn.imdb.images.data{i},2) + size(imdb_hand_crafted.imdb.images.data{i},2));
end
labels = zeros(number_of_samples, 1);
Is = double(zeros(32, 32, 3, number_of_samples));

% Accumulate all the data in the corresponding matrices
iterator = 1;
for i = 1 : length(imdb_cnn.imdb.images.data)
    
    switch features
        case 'cnn'
            % Retrieve data
            X(iterator : iterator + size(imdb_cnn.imdb.images.data{i},1) - 1, :) = imdb_cnn.imdb.images.data{i};
            % Retrieve labels
            labels(iterator : iterator + size(imdb_cnn.imdb.images.data{i},1) - 1) = imdb_cnn.imdb.images.labels{i};
        case 'hand-crafted'
            % Retrieve data
            X(iterator : iterator + size(imdb_cnn.imdb.images.data{i},1) - 1, :) = imdb_hand_crafted.imdb.images.data{i};
            % Retrieve labels
            labels(iterator : iterator + size(imdb_cnn.imdb.images.data{i},1) - 1) = imdb_hand_crafted.imdb.images.labels{i};
        case 'all'
            % Retrieve data
            X(iterator : iterator + size(imdb_cnn.imdb.images.data{i},1) - 1, :) = cat(2, imdb_cnn.imdb.images.data{i}, imdb_hand_crafted.imdb.images.data{i});
            % Retrieve labels
            labels(iterator : iterator + size(imdb_cnn.imdb.images.data{i},1) - 1) = imdb_cnn.imdb.images.labels{i};
    end
    % Retrieve windows
    Is(:, :, :, iterator : iterator + size(imdb_cnn.imdb.images.data{i},1) - 1) = uint8((windows.imdb.images.data{i} + detector.net.meta.trainOpts.dataMean));
    
    % Update the iterator
    iterator = iterator + size(imdb_cnn.imdb.images.data{i}, 1); 
end

% 
mean_value = mean(X);
std_value = std(X);
X = bsxfun(@minus, X, mean_value);
X = bsxfun(@rdivide, X,std_value);

mapped_X = tsne(X, labels, 2, size(X, 2), 50);
save(strcat('C:\_dr_tbme\DIARETDB1\test\red-lesions_candidates_data\mapped_X_', features ,'.mat'), 'mapped_X');

%%

figure, gscatter(mapped_X(:,2), -mapped_X(:,1), labels, 'rb', 'xo');
legend('Non lesions (false positive candidates)','True lesions (true positive candidates)');

mappedX = bsxfun(@minus, mapped_X, min(mapped_X));
mappedX = bsxfun(@rdivide, mappedX, max(mappedX));

N = size(mappedX, 1);
S = 2000; % Size of the embedding image
G = 255 * ones(S, S, 3, 'uint8');
s = 32;

Ntake = N;
for i = 1 : Ntake
    
    if mod(i, 100) == 0
        fprintf('Added %d/%d...\n', i, Ntake);
    end
    
    % location
    a = ceil(mappedX(i, 1) * (S-s)+1);
    b = ceil(mappedX(i, 2) * (S-s)+1);
    a = a - mod(a-1, s) + 1;
    b = b - mod(b-1, s) + 1;
    if G(a,b,1) ~= 255
        continue % spot already filled
    end
    
    % Assign current image
    G(a : a+s-1, b:b+s-1, :) = Is(:,:,:,i);
    
end

figure, imshow(G);