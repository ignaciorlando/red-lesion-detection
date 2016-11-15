
% --------------------------------
% PREPARE TRAINING SET
% --------------------------------
% MA candidates
script_get_ma_candidates;
% Computation of features
script_get_ma_detection_training_set;

% --------------------------------
% TRAIN THE MODEL
% --------------------------------
% Train the model
script_train_ma_detection_model;

% --------------------------------
% PREPARE THE TEST SET
% --------------------------------
% MA candidates on the test set
script_get_ma_candidates;
% Computation of the features
script_get_ma_detection_test_set;

% --------------------------------
% SEGMENT THE CANDIDATES ON A NEW SET
% --------------------------------
script_segment_ma;