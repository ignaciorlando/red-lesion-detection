
function [imdb] = get_red_lesion_data_to_classify(dataset_to_extract_data, features_source, type_of_lesion, is_training, data_path, root_path, cnn_filename)

    % prepare image and ground truth paths
    image_path = fullfile(root_path, dataset_to_extract_data, 'images');
    masks_path = fullfile(root_path, dataset_to_extract_data, 'masks');
    gt_path = fullfile(root_path, dataset_to_extract_data, type_of_lesion);
    % prepare data path and MA candidate path 
    ma_candidate_path = fullfile(data_path, dataset_to_extract_data, strcat(type_of_lesion, '_candidates'));
    red_lesion_data_path = fullfile(data_path, dataset_to_extract_data, strcat(type_of_lesion, '_candidates_data'));   
    mkdir(red_lesion_data_path);
    
    % depending on the features source we will use different functions
    switch features_source
        case 'cnn-transfer'
            % load the cnn
            load(cnn_filename);
            if strcmp(detector.training_type, 'cnn-from-scratch') || strcmp(detector.training_type, 'from-scratch')
                [detector.net] = prepareCNNforExtractingFeatures(detector.net);
            end            
            % prepare red lesion data filename
            cnn_filename_parts = strsplit(cnn_filename, filesep);
            red_lesion_data_filename = fullfile(red_lesion_data_path, strcat('imdb-cnn-features-', cnn_filename_parts{end}, '-', type_of_lesion, '.mat'));
        case 'hand-crafted'
            % prepare folder and filenames
            segmentations_path = fullfile(data_path, dataset_to_extract_data, 'segmentations');
            % prepare red lesion data filename
            red_lesion_data_filename = fullfile(red_lesion_data_path, strcat('imdb-hand-crafted-', type_of_lesion, '.mat'));
        case 'combined'
            % load the cnn
            load(cnn_filename);
            if strcmp(detector.training_type, 'cnn-from-scratch') || strcmp(detector.training_type, 'from-scratch')
                [detector.net] = prepareCNNforExtractingFeatures(detector.net);
            end
            % prepare folder and filenames
            segmentations_path = fullfile(data_path, dataset_to_extract_data, 'segmentations');
            % both cnn and hand crafted features filenames has to be preset
            cnn_filename_parts = strsplit(cnn_filename, filesep);
            cnn_features_filename = fullfile(red_lesion_data_path, strcat('imdb-cnn-features-', cnn_filename_parts{end}, '-', type_of_lesion, '.mat'));
            hand_crafted_features_filename = fullfile(red_lesion_data_path, strcat('imdb-hand-crafted-', type_of_lesion, '.mat'));
        otherwise % 'cnn-from-scratch' or 'cnn-fine-tune'
            if ~(is_training)
                % load the cnn
                load(cnn_filename);
            end
            % prepare red lesion data filename
            red_lesion_data_filename = fullfile(red_lesion_data_path, strcat('imdb-red-lesions-windows-', type_of_lesion, '.mat'));
    end   
    
    
    if strcmp(features_source, 'combined')
        
        % if there exists the cnn features file, load it... if it does not,
        % create it
        if (exist(cnn_features_filename, 'file')==0)
            fprintf('CNN features file does not exist, so we have to compute the features. This might take a while\n');
            [imdb_cnn] = get_red_lesion_data_to_classify(dataset_to_extract_data, 'cnn-transfer', type_of_lesion, is_training, data_path, root_path, cnn_filename);
        end
        S.imdb_cnn = load(cnn_features_filename);
        imdb_cnn = S.imdb_cnn;
        
        % same for the hand crafted features
        if (exist(hand_crafted_features_filename, 'file')==0)
            fprintf('Hand crafted features file does not exist, so we have to compute the features. This might take a while\n');
            [imdb_hand_crafted] = get_red_lesion_data_to_classify(dataset_to_extract_data, 'hand-crafted', type_of_lesion, is_training, data_path, root_path, cnn_filename);
        end
        S.imdb_hand_crafted = load(hand_crafted_features_filename);
        imdb_hand_crafted = S.imdb_hand_crafted;
        
        if (is_training)
            % cat all the features within the same structures, and voilà
            imdb.images.candidates_pxs = imdb_cnn.imdb.images.candidates_pxs;
            imdb.images.image_id = imdb_cnn.imdb.images.image_id;
            imdb.images.labels = imdb_cnn.imdb.images.labels;
            imdb.images.set = imdb_cnn.imdb.images.set;
            imdb.images.data = cat(2, imdb_cnn.imdb.images.data, imdb_hand_crafted.imdb.images.data);
        else
            imdb.images.candidates_pxs = imdb_cnn.imdb.images.candidates_pxs;
            imdb.images.data = imdb_cnn.imdb.images.data;
            imdb.images.labels = imdb_cnn.imdb.images.labels;
            for i = 1 : length(imdb_hand_crafted.imdb.images.data)
                imdb.images.data{i} = cat(2, imdb.images.data{i}, imdb_hand_crafted.imdb.images.data{i});
            end
        end
        
    else
        
        % check if the training data file exists
        if (exist(red_lesion_data_filename, 'file')~=0)

            % load the training data file and return the values
            load(red_lesion_data_filename);

        else

            % if it doesn't exists...

            % get image filenames
            image_filenames = getMultipleImagesFileNames(image_path);
            % get masks filenames
            masks_filenames = getMultipleImagesFileNames(masks_path);
            % get ma candidate filenames
            ma_candidate_filenames = getMultipleImagesFileNames(ma_candidate_path);
            % get labels filename
            gt_filenames = getMultipleImagesFileNames(gt_path);
            if strcmp(features_source, 'hand-crafted')
                % get segmentations filenames
                segmentations_filenames = getMultipleImagesFileNames(segmentations_path);
            end

            % initialize a struct with data
            if (is_training)
                imdb.images.data = [];
                imdb.images.labels = [];
                imdb.images.candidates_pxs = {};
                imdb.images.image_id = [];
            else
                imdb.images.data = cell(length(image_filenames), 1);
                imdb.images.labels = cell(length(image_filenames), 1);
                imdb.images.candidates_pxs = cell(length(image_filenames), 1);
            end

            % for each of the images
            for i = 1 : length(image_filenames)

                fprintf('Extracting features from image %d/%d\n', i, length(image_filenames));

                % open image
                I = imread(fullfile(image_path, image_filenames{i}));
                % open mask
                mask = imread(fullfile(masks_path, masks_filenames{i})) > 0;
                % open ma_candidate
                ma_candidate = imread(fullfile(ma_candidate_path, ma_candidate_filenames{i}));
                % open ground truth label
                if isempty(gt_filenames)
                    gt = [];
                else
                    gt = imread(fullfile(gt_path, gt_filenames{i}));
                end


                switch features_source
                    case 'cnn-transfer'
                        % get CNN training data
                        [current_windows, current_labels, current_candidates_coordinates] = get_cnn_training_data(I, ma_candidate, gt, false, mask);
                        % remove training data mean to all the images
                        current_windows = bsxfun(@minus, single(current_windows), detector.net.meta.trainOpts.dataMean);
                        % retrieve features
                        res = vl_simplenn(detector.net, current_windows,[],[], 'mode', 'test') ;
                        current_features = squeeze(gather(res(end).x))';
                    case 'hand-crafted'
                        % open segmentation
                        segm = imread(fullfile(segmentations_path, segmentations_filenames{i}));
                        % compute features and retrieve pixels
                        [current_features, current_candidates_coordinates] = hand_crafted_features_extraction(ma_candidate, I, segm, mask);
                        % get the labels
                        if ~isempty(gt)
                            [current_labels] = getMaLabels(gt, current_candidates_coordinates);
                        else
                            current_labels = [];
                        end
                    otherwise % 'cnn-from-scratch' or 'cnn-fine-tune'
                        % get CNN training data
                        [current_windows, current_labels, current_candidates_coordinates] = get_cnn_training_data(I, ma_candidate, gt, false, mask);
                        % if it is training data, remove the mean value
                        if ~(is_training)
                            % remove training data mean to all the images
                            current_features = bsxfun(@minus, single(current_windows), detector.net.meta.trainOpts.dataMean);
                        else
                            current_features = current_windows;
                        end
                end


                % concatenate data
                if (is_training)
                    if strcmp(features_source, 'cnn-from-scratch')
                        imdb.images.data = cat(4, imdb.images.data, current_features);
                    else
                        imdb.images.data = cat(1, imdb.images.data, current_features);
                    end
                    imdb.images.labels = cat(1, imdb.images.labels, current_labels);
                    imdb.images.candidates_pxs = cat(1, imdb.images.candidates_pxs, {current_candidates_coordinates});
                    imdb.images.image_id = cat(1, imdb.images.image_id, i * ones(size(current_labels)));
                else
                    imdb.images.data{i} = current_features;
                    if ~isempty(current_labels)
                        imdb.images.labels{i} = current_labels;
                    end
                    imdb.images.candidates_pxs{i} = current_candidates_coordinates;
                end

            end

            % split data into training and validation
            if (is_training)
                imdb = prepareTrainingValidationSets(imdb);
            end

            % save all data
            save(red_lesion_data_filename, 'imdb','-v7.3');

        end
        
    end
    
end
