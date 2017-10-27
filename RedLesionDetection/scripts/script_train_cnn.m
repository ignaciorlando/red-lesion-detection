
% SCRIPT_TRAIN_CNN
% -------------------------------------------------------------------------
% This code is used for training a CNN from scratch. It is based on
% Matconvnet example for image classification in CIFAR-10. Please, edit 
% config_train_cnn to adjust parameters.
% -------------------------------------------------------------------------

config_train_cnn;

% Train a CNN for red lesion detection
[detector.net, info] = cnn_red_lesion_detection( ...
                               'datasetName', datasetName, ...
                               'inputDir', inputDir, ...
                               'expDir', expDir, ...
                               'objective', objective, ...
                               'typeOfLesion', type_of_lesion, ...
                               'learningOpts', learningOpts);
detector.method = 'cnn-from-scratch';
detector.training_type = 'cnn-from-scratch';
           
% If the convnet must be saved
if (save_model)
    [datasetTag] = generate_dataset_tag(datasetName);
    
    current_folder = fullfile(expDir, strcat('red-lesions-detection-model'), datasetTag, detector.method);
    mkdir(current_folder);
    
    save(fullfile(current_folder, strcat(detector.net.meta.string_parameters, '.mat')), 'detector');
end