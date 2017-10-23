
% SCRIPT_EXTRACT_LESION_CANDIDATES
% -------------------------------------------------------------------------
% This code is used for extracting red lesion candidates from a given data
% set. You must modify config_extract_lesion_candidates first.
% -------------------------------------------------------------------------

config_extract_lesion_candidates;

% prepare root path of data sets
root_path = fullfile(root_path, datasetName);
% prepare dataset path
dataset_path = fullfile(data_path, datasetName);
% prepare output path
output_path = fullfile(dataset_path, strcat(type_of_lesion, '_candidates'));
if (exist(output_path, 'dir') == 0)
    mkdir(output_path);
end

% Get all candidates from images
getLesionCandidatesFromDataset(fullfile(root_path, 'images'), ...
    fullfile(root_path, 'masks'), output_path, L0, step, L, K, px);
