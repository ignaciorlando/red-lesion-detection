
config_export_roc_annotations_to_xml;

% -------------------------------------------------------------------------
% prepare folder and filenames
% -------------------------------------------------------------------------

% replace bars in the name of the training and test sets
[dataset_tag_name] = generate_dataset_tag(dataset_name);

% prepare data path depending on the type of features source
partial_model_path_name = strcat(type_of_lesion, '_detector_model_', dataset_name, '-', features_source);
switch features_source
    case 'cnn-transfer'
        segmentation_model_type = strcat(type_of_lesion, '_segmentations-', features_source, '-', classifier);
    case 'hand-crafted'
        segmentation_model_type = strcat(type_of_lesion, '_segmentations-', features_source, '-', classifier);
    case 'cnn-from-scratch'
        segmentation_model_type = strcat(type_of_lesion, '_segmentations-', 'cnn-from-scratch');
    case 'cnn-fine-tune'
        segmentation_model_type = strcat(type_of_lesion, '_segmentations-', 'cnn-fine-tune');
end
roc_data_path = fullfile(test_data_path, dataset_name, segmentation_model_type);

% retrieve scores files
scores_files = dir(fullfile(roc_data_path, '*.mat'));
scores_files = {scores_files.name};
% -------------------------------------------------------------------------
% calculate xml file and save the file
% -------------------------------------------------------------------------

% get xml code
xml_code = get_xml_code_from_roc_scores(roc_data_path, scores_files);

% save file
fid = fopen(fullfile(roc_data_path, strcat('roc_', segmentation_model_type)),'wt');
fprintf(fid, xml_code);
fclose(fid);
