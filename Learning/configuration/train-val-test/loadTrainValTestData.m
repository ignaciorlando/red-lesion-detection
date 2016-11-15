
function [] = loadTrainValTestData(options)

    % if the train folder is the same than the test folder, check if there
    % is a file inside indicating the partition. if not, then we should
    % load files from both folders
    if (strcmp(options.trainFolder, options.testFolder))
        
        % build partition file name
        partition_file_name = fullfile(options.trainFolder, 'data_partition.mat');
        
        % if the file doesn't exist, then we should create a random split
        % and save it there
        if (exist(partition_file_name,'file')==0)
            
            
            
        else
            
            % load the partition file
            load(partition_file_name);
            
            train_val_splits(
            
        end
        
    else
        
        
        
    end


end