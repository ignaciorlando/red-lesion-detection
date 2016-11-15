
function [net, info] = cnn_ma_detector(varargin)
%function [net, info] = cnn_ma_detector( model_type, dataset_name, input_dir, exp_dir, network_type, augmented, varargin)
% CNN_MA_DETECTOR   Demonstrates MatConvNet on CIFAR-10
%    The demo includes two standard model: LeNet and Network in
%    Network (NIN). Use the 'modelType' option to choose one.

    % set default parameters
    opts.modelType = 'lenet';
    opts.datasetName = fullfile('DIARETDB1', 'train');
    opts.inputDir = '';
    opts.expDir = '';
    opts.networkType = 'simplenn';
    opts.augmented = true;
    opts.whitenData = 'true' ;
    opts.contrastNormalization = 'true' ;
    opts.transferLearningDatasetName = 'CIFAR-10';
    opts.trainingType = 'from-scratch';
    opts.imdbPath = '';
    opts.typeOfLesion = 'ma';
    opts.objective = 'softmax';
    opts.errorFunction = 'auc';
    opts.learningOpts = struct();
    % parse all parameters
    [opts, varargin] = vl_argparse(opts, varargin) ;
    
    % copy exp_dir
    opts.expDir = fullfile(opts.expDir, strcat(opts.typeOfLesion, '-cnn-data-', opts.modelType)) ;
    opts.dataDir = fullfile(opts.inputDir, opts.datasetName) ;
    [opts, varargin] = vl_argparse(opts, varargin) ;

    % copy input dir    
    opts.train = struct() ;
    opts = vl_argparse(opts, varargin) ;
    if ~isfield(opts.train, 'gpus'), opts.train.gpus = []; end;
    
    % train the CNN depending on the type of training
    switch opts.trainingType
        case 'from-scratch'
            [net, info] = train_cnn_from_scratch(opts) ;
        case 'fine-tune'
            [net, info] = train_cnn_with_fine_tuning(opts) ;
        case 'transfer'
            [net, info] = train_cnn_for_transferring(opts) ;  
    end
  
end


function [prev_folder, tag] = generate_file_tag(net, opts)

    % add epochs, learning rate, etc
    tag = [ ...
             opts.objective, ...
             '-', ...
             'lr=', num2str(net.meta.trainOpts.learningRate), ...
             '-', ...
             'ceps=', num2str(net.meta.trainOpts.convergenceThreshold), ...
             '-', ...
             'lreps=', num2str(net.meta.trainOpts.decayLRThreshold), ...
             '-', ...
             'wd=', num2str(net.meta.trainOpts.weightDecay), ...
             '-', ...
             'batch=', num2str(net.meta.trainOpts.batchSize), ...
             '-', ...
             'N=', num2str(net.meta.trainOpts.N), ...
             '-', ...
             'dp=', num2str(net.meta.trainOpts.p_dropout), ...
             '-', ...
             'fc=', num2str(net.meta.trainOpts.fc_layer), ...
         ];
    
    % and prepare the folders
    switch opts.trainingType
        case 'transfer'
            prev_folder = fullfile(opts.trainingType);
        case 'from-scratch'
            prev_folder = fullfile(generate_dataset_tag(opts.datasetName), opts.trainingType);
        case 'fine-tune'
            prev_folder = fullfile(generate_dataset_tag(opts.datasetName), opts.trainingType);
    end

end



% -------------------------------------------------------------------------
function [net, info] = train_cnn_from_scratch(opts)
% TRAIN_CNN_FROM_SCRATCH   Demonstrates MatConvNet on MA data set
%    The demo includes two standard model: LeNet and Network in
%    Network (NIN). Use the 'modelType' option to choose one.

    % ---------------------------------------------------------------------
    %                                                Prepare model and data
    % ---------------------------------------------------------------------
    
    switch opts.modelType
      case 'lenet'
        net = cnn_init(opts) ;
      case 'nin'
        %net = cnn_cifar_init_nin('networkType', opts.networkType) ;
      otherwise
        error('Unknown model type ''%s''.', opts.modelType) ;
    end

    [prev_folder, net.meta.string_parameters] = generate_file_tag(net, opts);
    opts.expDir = fullfile(opts.expDir, prev_folder, net.meta.string_parameters);
    mkdir(opts.expDir);
    opts.imdbPath = fullfile(opts.expDir, 'imdb.mat');
    
    % check whether the MA data file exists or not
    if exist(opts.imdbPath, 'file')
        % if the file already exists... load it
        imdb = load(opts.imdbPath) ;
    else
        % if it does not, generate the structure and save it
        imdb = getMaDB(opts) ;
        mkdir(opts.expDir) ;
        save(opts.imdbPath, '-struct', 'imdb', '-v7.3') ;
    end
    net.meta.classes.name = imdb.meta.classes(:)' ;

    % ---------------------------------------------------------------------
    %                                                                 Train
    % ---------------------------------------------------------------------

    switch opts.networkType
      case 'simplenn', trainfn = @cnn_ma_train ;
      %case 'dagnn', trainfn = @cnn_train_dag ;
    end

    [net, info] = trainfn(net, imdb, getBatch(opts), ...
      'expDir', opts.expDir, ...
      net.meta.trainOpts, ...
      opts.train, ...
      'val', find(imdb.images.set == 2)) ;
    net.meta.trainOpts.dataMean = imdb.meta.dataMean;

end

% -------------------------------------------------------------------------
function [net, info] = train_cnn_for_transferring(opts)
% TRAIN_CNN_FOR_TRANSFERRING   Demonstrates MatConvNet on CIFAR-10
%    The demo includes two standard model: LeNet and Network in
%    Network (NIN). Use the 'modelType' option to choose one.


    % ---------------------------------------------------------------------
    %                                                Prepare model and data
    % ---------------------------------------------------------------------

    % always use softmax
    opts.objective = 'softmax';
    
    switch opts.modelType
      case 'lenet'
        net = cnn_init(opts) ;
      case 'nin'
        %net = cnn_cifar_init_nin('networkType', opts.networkType) ;
      otherwise
        error('Unknown model type ''%s''.', opts.modelType) ;
    end

    % path to cifar-10 data
    opts.dataDir = opts.expDir;
    
    [prev_folder, net.meta.string_parameters] = generate_file_tag(net, opts);
    opts.expDir = fullfile(opts.expDir, prev_folder, net.meta.string_parameters);
    mkdir(opts.expDir);
    opts.imdbPath = fullfile(opts.expDir, 'imdb.mat');
    
    [path, filename, extension] = fileparts(opts.imdbPath);
    imdbPath_cifar = fullfile(path, strcat(filename, '-cifar', extension));
    % check whether the CIFAR-10 file exists or not
    if exist(imdbPath_cifar, 'file')
        % if the file already exists... load it
        imdb = load(imdbPath_cifar) ;
    else
        % if it does not, generate the structure and save it
        imdb = getCifarImdb(opts) ;
        mkdir(opts.expDir) ;
        save(imdbPath_cifar, '-struct', 'imdb', '-v7.3') ;
    end
    net.meta.classes.name = imdb.meta.classes(:)' ;

    % ---------------------------------------------------------------------
    %                                                                 Train
    % ---------------------------------------------------------------------

    switch opts.networkType
      case 'simplenn', trainfn = @cnn_ma_train ;
      %case 'dagnn', trainfn = @cnn_train_dag ;
    end

    % train the net
    [net, info] = trainfn(net, imdb, getBatch(opts), ...
      'expDir', opts.expDir, ...
      net.meta.trainOpts, ...
      opts.train, ...
      'val', find(imdb.images.set == 3)) ;
    net.meta.trainOpts.dataMean = imdb.meta.dataMean;  
    
    [net] = prepareCNNforExtractingFeatures(net);
%     % remove the last two layers
%     net.layers(end) = [];
%     net.layers(end) = [];
    
end

% -------------------------------------------------------------------------
function [net, info] = train_cnn_with_fine_tuning(opts)
% TRAIN_CNN_FROM_SCRATCH   Demonstrates MatConvNet on MA data set
%    The demo includes two standard model: LeNet and Network in
%    Network (NIN). Use the 'modelType' option to choose one.

    % ---------------------------------------------------------------------
    %                   Train the model on CIFAR as using transfer learning
    % ---------------------------------------------------------------------
    opts.trainingType = 'transfer';
    [net, info] = train_cnn_for_transferring(opts);

    % ---------------------------------------------------------------------
    %                                                Reset paths and load
    %                                                MA data
    % ---------------------------------------------------------------------
    
    % reset for fine-tune
    opts.trainingType = 'fine-tune';
    % set data dir
    opts.dataDir = fullfile(opts.inputDir, opts.datasetName) ;
    % assign mean image
    %opts.dataMean = net.meta.trainOpts.dataMean;
    
    switch opts.modelType
      case 'lenet'
        net = cnn_redefine(net, opts) ;
      case 'nin'
        %net = cnn_cifar_init_nin('networkType', opts.networkType) ;
      otherwise
        error('Unknown model type ''%s''.', opts.modelType) ;
    end
    
    [prev_folder, net.meta.string_parameters] = generate_file_tag(net, opts);
    opts.expDir = fullfile(opts.expDir, prev_folder, net.meta.string_parameters);
    mkdir(opts.expDir);
    opts.imdbPath = fullfile(opts.expDir, 'imdb.mat');
    
    % check whether the file exists or not
    if exist(opts.imdbPath, 'file')
        % if the file already exists... load it
        imdb = load(opts.imdbPath) ;
    else
        % if it does not, generate the structure and save it
        imdb = getMaDB(opts) ;
        mkdir(opts.expDir) ;
        save(opts.imdbPath, '-struct', 'imdb', '-v7.3') ;
    end
    net.meta.classes.name = imdb.meta.classes(:)' ;

    % ---------------------------------------------------------------------
    %                                                                 Train
    % ---------------------------------------------------------------------

    switch opts.networkType
      case 'simplenn', trainfn = @cnn_ma_train ;
      %case 'dagnn', trainfn = @cnn_train_dag ;
    end

    [net, info] = trainfn(net, imdb, getBatch(opts), ...
      'expDir', opts.expDir, ...
      net.meta.trainOpts, ...
      opts.train, ...
      'val', find(imdb.images.set == 2)) ;
  
end



% -------------------------------------------------------------------------
function imdb = getCifarImdb(opts)
% -------------------------------------------------------------------------
    % Preapre the imdb structure, returns image data with mean image subtracted
    unpackPath = fullfile(opts.dataDir, 'cifar-10-batches-mat');
    files = [arrayfun(@(n) sprintf('data_batch_%d.mat', n), 1:5, 'UniformOutput', false) ...
      {'test_batch.mat'}];
    files = cellfun(@(fn) fullfile(unpackPath, fn), files, 'UniformOutput', false);
    file_set = uint8([ones(1, 5), 3]);
    
    % If data is not in the folder, download it
    if any(cellfun(@(fn) ~exist(fn, 'file'), files))
      url = 'http://www.cs.toronto.edu/~kriz/cifar-10-matlab.tar.gz' ;
      fprintf('downloading %s\n', url) ;
      untar(url, opts.dataDir) ;
    end

    % Concatenate all the sets
    data = cell(1, numel(files));
    labels = cell(1, numel(files));
    sets = cell(1, numel(files));
    for fi = 1:numel(files)
      fd = load(files{fi}) ;
      data{fi} = permute(reshape(fd.data',32,32,3,[]),[2 1 3 4]) ;
      labels{fi} = fd.labels' + 1; % Index from 1
      sets{fi} = repmat(file_set(fi), size(labels{fi}));
    end
    set = cat(2, sets{:});
    data = single(cat(4, data{:}));
    labels = single(cat(2, labels{:})) ;

    % Preprocess all the data
    [data, opts] = preprocessData(data, set, opts);

    % Load batches
    clNames = load(fullfile(unpackPath, 'batches.meta.mat'));

    % Save data
    imdb.images.data = data ;
    imdb.images.labels = labels ;
    imdb.images.set = set;
    imdb.meta.sets = {'train', 'val', 'test'} ;
    imdb.meta.classes = clNames.label_names;
    imdb.meta.dataMean = opts.meanImage;
end

% -------------------------------------------------------------------------
function imdb = getMaDB(opts)
% -------------------------------------------------------------------------   
% Prepare the imdb structure, returns image data with mean image subtracted
   
    % load different files depending on the augmentation technique
    if strcmp(opts.augmented, 'true')
        % load data set
        data_filename = fullfile(opts.dataDir, strcat(opts.typeOfLesion, '_candidates_data'), strcat('imdb-red-lesions-windows-', opts.typeOfLesion, '-augmented.mat'));
    else
        % load data set
        data_filename = fullfile(opts.dataDir, strcat(opts.typeOfLesion, '_candidates_data'), strcat('imdb-red-lesions-windows-', opts.typeOfLesion, '.mat'));
    end
    
    % load different files depending on the augmentation technique
    load(data_filename);
    
    % if there is a permutation available
    if (isfield(imdb.images, 'permutation'))
        % copy permutation
        permutation = imdb.images.permutation;
    else
        % shuffle and transform data and labels to single
        permutation = randperm(size(imdb.images.data,4));
        imdb.images.permutation = permutation;
        % replace file
        save(data_filename, 'imdb', '-v7.3');
    end
    imdb.images.data = single(imdb.images.data(:,:,:,permutation));
    imdb.images.labels = single(imdb.images.labels(permutation))' + 1;

    % in any case, 70% will be used for training and the remaining
    % for validation
    imdb.images.set = cat(1, ones(length(1:round(0.7*length(imdb.images.labels))), 1), 2 * ones(length(round(0.7*length(imdb.images.labels)+1:length(imdb.images.labels))), 1));
    
    % preprocess data
    [imdb.images.data, opts] = preprocessData(imdb.images.data, imdb.images.set, opts);
    
    % calculate the number of negative and positive samples
    n_neg = sum(sum(imdb.images.labels(imdb.images.set==1)==1));
    n_pos = sum(sum(imdb.images.labels(imdb.images.set==1)==2));
    
    % beta is a parameter that is used for class balanced softmax loss
    beta = n_neg / (n_neg + n_pos);
    % gamma is a parameter that is used to scale the class balanced softmax
    % loss so the weight decay and the learning rate are preserved
    gamma = (n_neg + n_pos) / ( (1-beta) * n_neg + beta * n_pos );
    
    % assign to the structure
    imdb.meta.sets = {'train', 'val', 'test'} ;
    imdb.meta.classes = {'no', 'yes'};
    imdb.meta.dataMean = opts.meanImage;
    imdb.meta.beta = beta;
    imdb.meta.gamma = gamma;
    
end

% -------------------------------------------------------------------------
function fn = getBatch(opts)
% -------------------------------------------------------------------------
switch lower(opts.networkType)
  case 'simplenn'
    fn = @(x,y) getSimpleNNBatch(x,y) ;
  case 'dagnn'
    bopts = struct('numGpus', numel(opts.train.gpus)) ;
    fn = @(x,y) getDagNNBatch(bopts,x,y) ;
end
end

% -------------------------------------------------------------------------
function [images, labels] = getSimpleNNBatch(imdb, batch)
% -------------------------------------------------------------------------
images = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.labels(1,batch) ;
if rand > 0.5, images=fliplr(images) ; end
end

% -------------------------------------------------------------------------
function inputs = getDagNNBatch(opts, imdb, batch)
% -------------------------------------------------------------------------
images = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.labels(1,batch) ;
if rand > 0.5, images=fliplr(images) ; end
if opts.numGpus > 0
  images = gpuArray(images) ;
end
inputs = {'input', images, 'label', labels} ;
end

% -------------------------------------------------------------------------
function [data, opts] = preprocessData(data, set, opts)
% -------------------------------------------------------------------------

    % remove training data mean to all the images
    if (~isfield(opts, 'meanImage'))
        opts.meanImage = mean(data(:,:,:,set == 1), 4);
    end
    data = bsxfun(@minus, data, opts.meanImage);

    % normalize by image mean and std as suggested in `An Analysis of
    % Single-Layer Networks in Unsupervised Feature Learning` Adam
    % Coates, Honglak Lee, Andrew Y. Ng
    if strcmp(opts.contrastNormalization, 'true')
      z = reshape(data,[],size(data,4)) ;
      z = bsxfun(@minus, z, mean(z,1)) ;
      n = std(z,0,1) ;
      z = bsxfun(@times, z, mean(n) ./ max(n, 40)) ;
      data = reshape(z, 32, 32, 3, []) ;
    end
    
    % whiten data
    if strcmp(opts.whitenData, 'true')
      z = reshape(data,[],size(data,4)) ;
      W = z(:,set == 1)*z(:,set == 1)'/size(data,4) ;
      [V,D] = eig(W) ;
      % the scale is selected to approximately preserve the norm of W
      d2 = diag(D) ;
      en = sqrt(mean(d2)) ;
      z = V*diag(en./max(sqrt(d2), 10))*V'*z ;
      data = reshape(z, 32, 32, 3, []) ;
    end
end

