
function [bestModel, qualityOverValidation, bestParam] = learnCRFPotentials(config, trainingdata, validationdata)

    % Determine the type of metric to optimize during model selection
    if (isfield(config,'modelSelectionMetric' ~= 1))
        % By default, we optimize the parameters in terms of the MCC
        config.modelSelectionMetric = 'matthews';
    end
    better = -Inf;

    % If you want to find the best value of C according to the validation set
    if (config.learn.C == 1)

        % Get the best model and the best value of C according to the
        % validation set
        [bestModel, qualityOverValidation, bestParam, ~] = findBestC(config, trainingdata, validationdata, better);
        
    else

        % Set the value of C and print an alert
        fprintf('Training for C=%d\n', config.C.value);
        bestC = config.C.value;

        % Train the model
        [bestModel, bestParam, state] = sosvmCallback(config, trainingdata);

        % Segment the validation set
        [segs, currentQualityMeasures] = getBunchSegmentations2(config, validationdata, bestModel);
        qualityOverValidation = getAverageMeasures2(currentQualityMeasures)
        
        bestParam.qualitiesOnValidationSet = qualityOverValidation.qualities;
        bestParam.bestCvalue = bestC;
        
        qualityOverValidation.segs = segs;

    end
    
    fprintf('Best quality values\n');
    disp(qualityOverValidation);        
    
end




function [bestModel, qualityOverValidation, bestParam, better] = findBestC(config, trainingdata, validationdata, better) 

    % Look for the best value of C according to the validation set
    bestCvalue = 0;
    bestModel = [];
    lastC = false;
    
    
    % Initialize qualities on validation set for each value of c table
    qualitiesOnValidationSet = zeros(8, abs(config.C.initialPower - config.C.lastPower) + 1);
    
    count = 1;
    cvalues = config.C.initialPower:config.C.lastPower;
    for i = 1 : length(cvalues);

        % Set the value of C and print an alert
        config.C.value = 10.0^cvalues(i);
        fprintf('Training for C=%d\n', config.C.value);


        %try
            % Train the model            
            [model, config, state] = sosvmCallback(config, trainingdata);

            % Segment the validation set
            [segs, currentQualityMeasures] = getBunchSegmentations2(config, validationdata, model);

            % Compute average quality metrics on the validation set
            averageMeasures = getAverageMeasures2(currentQualityMeasures);
            
            % Assign results to the table
            qualitiesOnValidationSet(:, count) = averageMeasures.qualities;
            

            % Assign the first value of C as the best value
            if (i == config.C.initialPower)
                
                % select the first model as the best one
                bestCvalue = 10.0^cvalues(i);
                bestModel = model;
                bestParam = config;
                bestParam.bestCvalue = bestCvalue;
                bestParam.qualitiesOnValidationSet = qualitiesOnValidationSet;
                % assign quality over validation the validation set
                qualityOverValidation = averageMeasures;
                qualityOverValidation.segs = segs;
                % recover the value of the evaluation metric
                better = getfield(averageMeasures, config.modelSelectionMetric);
                
            end

            % Extract the current quality
            currentQuality = getfield(averageMeasures, config.modelSelectionMetric);

            % Check if the current quality is better than the previous one
            if (currentQuality > better)
                
                better = currentQuality;
                bestCvalue = 10.0^cvalues(i);
                bestModel = model;
                bestParam = config;
                bestParam.bestCvalue = bestCvalue;
                bestParam.qualitiesOnValidationSet = qualitiesOnValidationSet;
                qualityOverValidation = averageMeasures;
                qualityOverValidation.segs = segs;
                
            end
                
            % Print quality value of the evaluation
            fprintf(strcat('Results over validation set. C=%d. ', config.modelSelectionMetric,'=%d\n'), 10.0^cvalues(i), getfield(averageMeasures, config.modelSelectionMetric));
            averageMeasures
            
            % Check if the quality is lower than 0.5. In that case, stop
            % tunning C
            %lastC = currentQuality < 0.5;
            lastC = 0;
            
            count = count + 1;
            
            
%        catch exception
%            
%             % Show error mesage
%             fprintf(strcat('It blows for C=',num2str(10.0^i),'\n\n'));
%             disp(exception);
%             
%             % If the exception is related to the optimization process or a
%             % violation of the positivity constraint...
%             lastC = strcmp(exception.identifier,'MATLAB:dot:InputSizeMismatch') || strcmp(exception.identifier,'');
%             
%         end

    end
    
    % Print an alert
    fprintf(strcat('Optimization finished. Best C=%d. ', config.modelSelectionMetric,'=%d\n'), bestCvalue, better);
            
end