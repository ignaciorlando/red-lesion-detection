
config_organize_roch_data

%% set up input and output folders
fprintf('Setting up and creating folders\n');

% set up input folder
training_input_dir = fullfile(root_folder, 'ROCtraining', 'ROCtraining');
test_input_dir = fullfile(root_folder, 'ROCtestImages', 'images');

% set up output folders
% training images
training_output_dir_images = fullfile(output_folder, 'ROCh', 'train', 'images');
mkdir(training_output_dir_images);
% training labels
training_output_dir_labels = fullfile(output_folder, 'ROCh', 'train', 'ma');
mkdir(training_output_dir_labels);
% test images
test_output_dir_images = fullfile(output_folder, 'ROCh', 'test', 'images');
mkdir(test_output_dir_images);

%% copy the files
fprintf('Copying files\n');

% retrieve all the images in the training and test folders
training_file_names = dir(fullfile(training_input_dir, '*.jpg'));
training_file_names = {training_file_names.name};
test_file_names = dir(fullfile(test_input_dir, '*.jpg'));
test_file_names = {test_file_names.name};

% copy all the images on the training set
fprintf('Copying training set images\n');
copy_roch_files(training_file_names, training_input_dir, training_output_dir_images);
% and on the test set
fprintf('Copying test set images\n');
copy_roch_files(test_file_names, test_input_dir, test_output_dir_images);

%% generate binary masks using the XML file
fprintf('Generating labels\n');

% prepare XML filename
xml_filename = fullfile(training_input_dir, 'annotations-consensus-ma-only.xml');
% retrieve all the labels
fprintf('Retrieving labels from the XML file\n');
[labels, filenames] = get_ROC_labels(xml_filename, training_input_dir, training_output_dir_labels, probability);

%% generate masks

% generate FOV masks on training data
fprintf('Generating FOV masks on training data...\n');
root = fullfile(output_folder, 'ROCh', 'train');
threshold = 0.26;
GenerateFOVMasks;

% generate FOV masks on test data
fprintf('Generating FOV masks on test data...\n');
root = fullfile(output_folder, 'ROCh', 'test');
threshold = 0.26;
GenerateFOVMasks;

%% crop images, labels and so on

if perform_cropping

    % cropping training data set
    fprintf('Cropping training set data...\n');
    % - path where the images to crop are
    sourcePaths = { ...
        fullfile(output_folder, 'ROCh', 'train', 'images'), ...
        fullfile(output_folder, 'ROCh', 'train', 'ma'), ...
        fullfile(output_folder, 'ROCh', 'train', 'masks'), ...
    };
    % - paths where the images to be cropped will be saved
    outputPaths = { ...
        fullfile(output_folder, 'ROCh', 'train', 'images'), ...
        fullfile(output_folder, 'ROCh', 'train', 'ma'), ...
        fullfile(output_folder, 'ROCh', 'train', 'masks'), ...    
    };
    % - masks to be used to crop the images
    maskPaths = fullfile(output_folder, 'ROCh', 'train', 'masks');
    % crop!!
    script_cropFOVSet;

    % cropping training data set
    fprintf('Cropping test set data...\n');
    % - path where the images to crop are
    sourcePaths = { ...
        fullfile(output_folder, 'ROCh', 'test', 'images'), ...
        fullfile(output_folder, 'ROCh', 'test', 'masks'), ...
    };
    % - paths where the images to be cropped will be saved
    outputPaths = { ...
        fullfile(output_folder, 'ROCh', 'test', 'images'), ...
        fullfile(output_folder, 'ROCh', 'test', 'masks'), ...    
    };
    % - masks to be used to crop the images
    maskPaths = fullfile(output_folder, 'ROCh', 'test', 'masks');
    % crop!!
    script_cropFOVSet;
    
end
