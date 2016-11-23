
config_evaluate_screening_performance;

% -------------------------------------------------------------------------
% prepare folder and filenames
% -------------------------------------------------------------------------

% update folder where the scores are saved
root_scores_folder = fullfile(root_scores_folder, dataset_name, strcat(type_of_lesion, '-segmentations'));

% generate data set tag
[dataset_tag_name] = generate_dataset_tag(dataset_name);

% prepare the scores folder
scores_folder = fullfile(root_scores_folder, features_source, trained_model_name);
if strcmp(features_source, 'combined')
    scores_folder = fullfile(scores_folder, cnn_filename);
end

% retrieve all the names of the .mat files with the scores
main_folder_dir = dir(fullfile(scores_folder, '*.mat'));
score_filenames = extractfield(main_folder_dir, 'name');

% retrieve also the labels
load(labels_file);
labels = labels.dr;
switch type_of_evaluation
    case 'screening'
        labels = 2 * (labels > 0) - 1;
    case 'need-to-referral'
        labels = 2 * (labels > 1) - 1;
end

% now that we know that everything is working, lets create the output
% folders
output_path = fullfile(results_path, 'screening-results', dataset_tag_name, features_source, trained_model_name);
if strcmp(features_source, 'combined')
    output_path = fullfile(output_path, cnn_filename);
end
mkdir(output_path);


% -------------------------------------------------------------------------
% compute the maximum probability per each of the images
% -------------------------------------------------------------------------

% initialize the array of probabilities
dr_probability = zeros(length(score_filenames), 1);

% for each of the score maps
for i = 1 : length(score_filenames)
    % open the score map
    load(fullfile(scores_folder, score_filenames{i}));
    % get the maximum probability of the score map
    dr_probability(i) = max(score_map(:));
end


% -------------------------------------------------------------------------
% moment of truth: plot the roc curve with this performance
% -------------------------------------------------------------------------

% compute the roc curve
[tpr, tnr, info] = vl_roc(labels, dr_probability);
auc = info.auc;

% plot it
figure;
plot(1-tnr, tpr, 'LineWidth', 2);
box on
grid on
legend(['AUC = ', num2str(auc)], 'Location', 'southeast');
xlabel('1 - Per-image specificity');
ylabel('Per-image sensitivity');

% save everything we did
save(fullfile(output_path, strcat(type_of_evaluation,'-performance.mat')), 'dr_probability', 'labels', 'auc', 'tpr', 'tnr');
savefig(fullfile(output_path, strcat(type_of_evaluation,'-roc-curve.fig')));