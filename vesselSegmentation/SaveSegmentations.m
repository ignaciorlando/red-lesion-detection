
function SaveSegmentations(root, config, results, model, filenames)

    if (sum(config.features.pairwise.pairwiseFeatures)==0)
        tag = 'up';
    else
        if (strcmp(config.crfVersion, 'fully-connected'))
            tag = 'fccrf';
        else
            tag = 'lnbcrf';
        end
    end


    for i = 1 : length(results.segmentations);
        imwrite(results.segmentations{i}, strcat(root, filesep, filenames{i}, '_', tag, '.png'));
    end
    results.segmentations = [];
    save(strcat(root, filesep, 'results.mat'), 'results');
    save(strcat(root, filesep, 'model.mat'), 'model');
    save(strcat(root, filesep, 'config.mat'), 'config');
    
end