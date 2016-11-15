
function [datasetTag] = generate_dataset_tag(datasetName)

    % generate data set tag
    datasetTag = datasetName;
    k = strfind(datasetTag, filesep);
    if (~isempty(k))
        datasetTag(k) = '_';
    end

end