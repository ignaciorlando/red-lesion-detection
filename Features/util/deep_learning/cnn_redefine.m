
function net = cnn_redefine(net, opts, varargin)

    opts = vl_argparse(opts, varargin) ;

    % assign the parameters depending on the type of training
    net.meta.trainOpts.batchSize = 100;
    net.meta.trainOpts.numClasses = 2;
    net.meta.trainOpts.decay_at_epochs = [15 10 5];    
    initial_learning_rate = 0.01;
    learning_rate_decay_factor = 1/10;
%             net.meta.trainOpts.batchSize = 100;
%             net.meta.trainOpts.numClasses = 2;
%             net.meta.trainOpts.decay_at_epochs = [15 10];    
%             initial_learning_rate = 0.005;
%             learning_rate_decay_factor = 1/10;

    lr = [.1 2] ;


    % Block 5: FC + RELU
    net.layers{end+1} = struct('type', 'conv', ...
                               'weights', {{0.05*randn(1,1,64,2, 'single'), zeros(1,2,'single')}}, ...
                               'learningRate', .1*lr, ...
                               'stride', 1, ...
                               'pad', 0) ;
    % Softmax Loss layer
    net.layers{end+1} = struct('type', 'softmaxloss') ;

    % Meta parameters
    net.meta.trainOpts.learningRate = [];
    current_learning_rate = initial_learning_rate;
    for i = 1 : length(net.meta.trainOpts.decay_at_epochs)
        net.meta.trainOpts.learningRate = cat(2, net.meta.trainOpts.learningRate, current_learning_rate * ones(1,net.meta.trainOpts.decay_at_epochs(i)));
        current_learning_rate = current_learning_rate * learning_rate_decay_factor;
    end
    net.meta.trainOpts.numEpochs = numel(net.meta.trainOpts.learningRate) ;
    

    % Switch to DagNN if requested
    switch lower(opts.networkType)
      case 'simplenn'
        % done
      case 'dagnn'
        net = dagnn.DagNN.fromSimpleNN(net, 'canonicalNames', true) ;
        net.addLayer('error', dagnn.Loss('loss', 'classerror'), ...
                 {'prediction','label'}, 'error') ;
      otherwise
        assert(false) ;
    end

end
