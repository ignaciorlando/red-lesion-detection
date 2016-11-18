
% CONFIG_TRAIN_CNN
% -------------------------------------------------------------------------
% This code is called by script_train_cnn to fix the parameters for
% training a CNN.
% -------------------------------------------------------------------------

% Name of the data set for training
datasetName = fullfile('DIARETDB1', 'train');
%datasetName = fullfile('DIARETDB1-ROCh', 'train');

% Input folder
inputDir = 'C:\_diabetic_retinopathy_testing_software';

% Type of lesion
type_of_lesion = 'red-lesions';

% Folder to export epoch statistics
expDir = strcat('C:\my_temp_folder\dr-screening\data-', type_of_lesion);

% Indicate if the model has to be saved
save_model = false;
%save_model = true;

% Is the data set augmented?
augmented = 'true';
%augmented = false;

% Select loss function to optimize
objective = 'softmax';
%objective = 'classbalancingsoftmax';

% Assign parameters according to the objective function
switch objective
    
    % Softmax loss (cross entropy loss)
    case 'softmax'
        % initial learning rate
        learningOpts.from_scratch.initial_learning_rate = 0.05;
        % threshold used for convergence
        learningOpts.from_scratch.convergence_threshold = 1e-4;
        % threshold used for learning rate decay
        learningOpts.from_scratch.decay_lr_threshold = 1e-2;   
        % weight decay factor
        learningOpts.from_scratch.weightDecay = 0.005 ;
        % batch size
        learningOpts.from_scratch.batchSize = 100;
        % number of epochs used to estimate mean loss function in previous
        % epochs (for both convergence and learning rate decay)
        learningOpts.from_scratch.N = 10;
        % dropout probability
        learningOpts.from_scratch.p_dropout = 0.05;
        % size of the fully connected layer
        learningOpts.from_scratch.fc_layer = 128;
        % minimum number of epochs
        learningOpts.from_scratch.min_epochs = 15;
        % maximum number of epochs
        learningOpts.from_scratch.max_epochs = 200;
        % decay factor used to reduce the learning rate
        learningOpts.from_scratch.lr_decay_factor = 1/2;

    % Class balanced softmax loss
    case 'classbalancingsoftmax'
        % initial learning rate        
        learningOpts.from_scratch.initial_learning_rate = 0.05;
        % threshold used for convergence        
        learningOpts.from_scratch.convergence_threshold = 1e-4;
        % threshold used for learning rate decay        
        learningOpts.from_scratch.decay_lr_threshold = 1e-2;   
        % weight decay factor
        learningOpts.from_scratch.weightDecay = 0.005 ;
        % batch size        
        learningOpts.from_scratch.batchSize = 100;
        % number of epochs used to estimate mean loss function in previous
        % epochs (for both convergence and learning rate decay)        
        learningOpts.from_scratch.N = 10;
        % dropout probability        
        learningOpts.from_scratch.p_dropout = 0.01;
        % size of the fully connected layer        
        learningOpts.from_scratch.fc_layer = 128;
        % minimum number of epochs
        learningOpts.from_scratch.min_epochs = 15;
        % maximum number of epochs        
        learningOpts.from_scratch.max_epochs = 200;
        % decay factor used to reduce the learning rate        
        learningOpts.from_scratch.lr_decay_factor = 1/2;

end
