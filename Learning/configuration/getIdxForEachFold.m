
function [folds, filenames] = getIdxForEachFold(labels, options)

    % if the folds file does not exist
    if (exist(options.folds_file, 'file')==0)

        % Retrieve image filenames
        filenames = getMultipleImagesFileNames(fullfile(options.rootFolder, 'images'));
        
        % if only one fold is selected, then the set must be split in
        % training and validation
        if options.numFolds==1
            [folds, ~] = train_val_splits(length(filenames), [], options);
        else
            % Lets divide each subset in a number of folds.
            [folds, ~] = crossValidationSplits(labels.dr, options.numFolds, [], options);
        end
        
        save(options.folds_file, 'folds', 'filenames');
        
        fprintf('\nI have created splits for each fold. I will save them in the Data folder\n');
        
    else
        
        % Just load the file, and almost everything will be done!
        load(options.folds_file);
        
        fprintf('\nI found a split in the Data folder. You know what? I will use it\n');
        
    end

end