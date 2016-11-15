
function [training_ma_features, training_ma_labels, validation_ma_features, validation_ma_labels] = ...
    get_cnn_transferred_training_set(training_path, dataset_name, cnn_path)

    % load training data
    imdb = load(fullfile(training_path, 'imdb.mat'));
    % load the net
    k = strfind(dataset_name, filesep);
    if (~isempty(k)), dataset_name(k) = '_'; end
    load(fullfile(cnn_path, strcat('ma_detector_model_', dataset_name, '-cnn-transfer.mat')));
    
    % -------------------------------------------------------------------------
    % GENERATE TRAINING/VALIDATION SETS
    % -------------------------------------------------------------------------
    
    % remove training data mean to all the images
    images.data = bsxfun(@minus, single(imdb.images.data), ma_detector.net.meta.trainOpts.dataMean);
    % run the CNN-S
    res = vl_simplenn(ma_detector.net, imdb.images.data) ;
    all_features = squeeze(gather(res(end).x))';
    
    % retrieve features and labels from the training set
    training_ma_features = all_features(imdb.images.set==1,:);
    training_ma_labels = imdb.images.labels(imdb.images.set==1)';
    
    % retrieve features and labels from the validation set
    validation_ma_features = all_features(imdb.images.set==2,:);
    validation_ma_labels = imdb.images.labels(imdb.images.set==2)';

    
end