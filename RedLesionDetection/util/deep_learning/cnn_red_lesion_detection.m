
function [net, info] = cnn_red_lesion_detection(varargin)

    % set default parameters
    opts.datasetName = fullfile('DIARETDB1', 'train');
    opts.inputDir = '';
    opts.expDir = '';
    opts.imdbPath = '';
    opts.objective = 'softmax';
    opts.typeOfLesion = 'red-lesions';
    opts.learningOpts = struct();
    % parse all parameters
    [opts, varargin] = vl_argparse(opts, varargin) ;
    
    % copy exp_dir
    opts.expDir = fullfile(opts.expDir, 'red-lesion-cnn-data-lenet') ;
    opts.dataDir = fullfile(opts.inputDir, opts.datasetName) ;
    [opts, varargin] = vl_argparse(opts, varargin) ;

    % copy input dir    
    opts.train = struct() ;
    opts = vl_argparse(opts, varargin) ;
    if ~isfield(opts.train, 'gpus'), opts.train.gpus = []; end;
    
    % train the cnn from scratch
    [net, info] = train_cnn_from_scratch(opts) ;
  
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
    prev_folder = fullfile(generate_dataset_tag(opts.datasetName), 'cnn-from-scratch');

end



% -------------------------------------------------------------------------
function [net, info] = train_cnn_from_scratch(opts)

    % ---------------------------------------------------------------------
    %                                                Prepare model and data
    % ---------------------------------------------------------------------
    
    % Initialize the network
    net = cnn_init(opts) ;

    % Initialize a MAT file with all the training data
    [prev_folder, net.meta.string_parameters] = generate_file_tag(net, opts);
    opts.expDir = fullfile(opts.expDir, prev_folder, net.meta.string_parameters);
    mkdir(opts.expDir);
    opts.imdbPath = fullfile(opts.expDir, 'imdb.mat');
    
    % check whether the red lesions data file exists or not
    if exist(opts.imdbPath, 'file')
        % if the file already exists... load it
        imdb = load(opts.imdbPath) ;
    else
        % if it does not, generate the structure and save it
        imdb = getRedLesionDB(opts) ;
        mkdir(opts.expDir) ;
        save(opts.imdbPath, '-struct', 'imdb', '-v7.3') ;
    end
    net.meta.classes.name = imdb.meta.classes(:)' ;

    % ---------------------------------------------------------------------
    %                                                                 Train
    % ---------------------------------------------------------------------
    
    [net, info] = cnn_red_lesions_train(net, imdb, getBatch(opts), ...
      'expDir', opts.expDir, ...
      net.meta.trainOpts, ...
      opts.train, ...
      'val', find(imdb.images.set == 2)) ;
    net.meta.trainOpts.dataMean = imdb.meta.dataMean;

end


% -------------------------------------------------------------------------
function imdb = getRedLesionDB(opts)
% -------------------------------------------------------------------------   
% Prepare the imdb structure, returns image data with mean image subtracted
   
    % load data set
    data_filename = fullfile(opts.dataDir, strcat(opts.typeOfLesion, '_candidates_data'), strcat('imdb-red-lesions-windows-', opts.typeOfLesion, '-augmented.mat'));
    
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
    fn = @(x,y) getSimpleNNBatch(x,y) ;
end

% -------------------------------------------------------------------------
function [images, labels] = getSimpleNNBatch(imdb, batch)
% -------------------------------------------------------------------------
    images = imdb.images.data(:,:,:,batch) ;
    labels = imdb.images.labels(1,batch) ;
    if rand > 0.5, images=fliplr(images) ; end
end

% -------------------------------------------------------------------------
function [data, opts] = preprocessData(data, set, opts)
% -------------------------------------------------------------------------
    % remove training data mean to all the images
    if (~isfield(opts, 'meanImage'))
        opts.meanImage = mean(data(:,:,:,set == 1), 4);
    end
    data = bsxfun(@minus, data, opts.meanImage);
end

