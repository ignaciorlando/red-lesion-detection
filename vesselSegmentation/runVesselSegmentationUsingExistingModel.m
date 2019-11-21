
function [results] = runVesselSegmentationUsingExistingModel(config, model)
    
    % if there are labels in the test data
    if config.thereAreLabelsInTheTestData
        % Open training data labels
        allLabels = openVesselLabels(fullfile(config.test_data_path, 'labels'));
    else
        allLabels = [];
    end

    % set image and mask paths
    imagesPath = fullfile(config.test_data_path, 'images');
    masksPath = fullfile(config.test_data_path, 'masks');
    
    % retrieve image names...
    imgNames = getMultipleImagesFileNames(imagesPath);
    % ...and mask names
    mskNames = getMultipleImagesFileNames(masksPath);
    
    % initialize an array of quality values
    results.qualityMeasures.se = zeros(size(imgNames));
    results.qualityMeasures.sp = zeros(size(imgNames));
    results.qualityMeasures.acc = zeros(size(imgNames));
    results.qualityMeasures.precision = zeros(size(imgNames));
    results.qualityMeasures.fMeasure = zeros(size(imgNames));
    results.qualityMeasures.matthews = zeros(size(imgNames));
    
    % for each image, verify if the feature file exist. if it is not there,
    % then we should compute it
    for i = 1 : length(imgNames)

        fprintf('Extracting features from %i/%i\n',i,length(imgNames));
        
        % open the mask
        mask = imread(fullfile(masksPath, mskNames{i})) > 0;
        mask = mask(:,:,1);
        % resize it
        mask = imresize(mask, config.downsample_factor);
        testdata.masks{1} = mask;

        % UNARY FEATURES --------------------------------------------------
        selectedFeatures = config.features.unary.unaryFeatures;
        config2 = config;
        
        % Remove features we will not include
        config2.features.features(selectedFeatures==0) = [];
        config2.features.featureParameters(selectedFeatures==0) = [];
        config2.features.featureNames(selectedFeatures==0) = [];
        
        fprintf(strcat('Computing unary features\n'));
        % get the features of this image
        testdata.unaryFeatures = extractFeaturesFromSingleImage(imagesPath, imgNames{i}, mask, config2, true);
        % get features dimensionality
        config.features.unary.unaryDimensionality = size(testdata.unaryFeatures, 2);
        %
        if (~iscell(testdata.unaryFeatures))
            testdata.unaryFeatures = {testdata.unaryFeatures};
        end
        % get image filename
        filename = imgNames{i};
        if (~iscell(filename))
            testdata.filenames = {filename(1:end-4)};
        else
            testdata.filenames = filename(1:end-4);
        end
        
        % PAIRWISE FEATURES -----------------------------------------------
        selectedFeatures = config.features.pairwise.pairwiseFeatures;
        config2 = config;
        
        % Remove features we will not include
        config2.features.features(selectedFeatures==0) = [];
        config2.features.featureParameters(selectedFeatures==0) = [];
        config2.features.featureNames(selectedFeatures==0) = [];
        
        fprintf(strcat('Computing pairwise features\n'));
        % get the features of this image
        pairwisefeatures = {extractFeaturesFromSingleImage(imagesPath, imgNames{i}, mask, config2, false)};
        % get features dimensionality
        config.features.unary.pairwiseDimensionality = size(pairwisefeatures, 2);
        % compute the pairwise kernels
        testdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, config.features.pairwise.pairwiseDeviations);
        % get current label
        if ~isempty(allLabels)
            testdata.labels{1} = allLabels{i};
        end
        
        % Segment test data to evaluate the model -------------------------
        [current_results.segmentations, current_results.qualityMeasures] = getBunchSegmentations2(config, testdata, model);
        
        % Save the segmentations ------------------------------------------
        SaveSegmentations(config.resultsPath, config, current_results, model, testdata.filenames);
        
        % Save current performance
        if ~isempty(allLabels)
            results.qualityMeasures.se(i) = current_results.qualityMeasures.se;
            results.qualityMeasures.sp(i) = current_results.qualityMeasures.sp;
            results.qualityMeasures.acc(i) = current_results.qualityMeasures.acc;
            results.qualityMeasures.precision(i) = current_results.qualityMeasures.precision;
            results.qualityMeasures.fMeasure(i) = current_results.qualityMeasures.fMeasure;
            results.qualityMeasures.matthews(i) = current_results.qualityMeasures.matthews;
        end
        
    end
       
    % Take average performance
    if ~isempty(allLabels)
        results.averageQualityMeasures.se = mean(results.qualityMeasures.se);
        results.averageQualityMeasures.sp = mean(results.qualityMeasures.sp);
        results.averageQualityMeasures.acc = mean(results.qualityMeasures.acc);
        results.averageQualityMeasures.precision = mean(results.qualityMeasures.precision);
        results.averageQualityMeasures.fMeasure = mean(results.qualityMeasures.fMeasure);
        results.averageQualityMeasures.matthews = mean(results.qualityMeasures.matthews);
    end
    
end