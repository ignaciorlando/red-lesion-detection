
function [filefullname] = encodeFileName(root, param, type)

    %training_dataset_uUNARIES_pPAIRWISES
    filefullname = strcat(root, filesep, type, '_', param.dataset, '_', ...
        'u', num2str(featuresToNumber(param.unaryFeatures)), '_', ...
        'p', num2str(featuresToNumber(param.pairwiseFeatures)), '.mat');


end



function [number] = featuresToNumber(selectedFeatures)

    % convert x to a string array
    str_x = num2str(selectedFeatures);
    str_x(isspace(str_x)) = '';
    % now use BIN2DEC to convert the binary 
    % string to a decimal number
    number = bin2dec(str_x);

end