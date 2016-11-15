
function [ma_segmentation, ma_score_map, scores] = segmentMA(ma_detector, I, features, pxs)

    % Create an empty image
    ma_segmentation = false(size(I,1), size(I,2));
    ma_score_map = zeros(size(I,1), size(I,2));

    % Initialize an array of scores
    scores = zeros(length(pxs), 1);
    
    % Preprocess according to the segmentation method
    switch ma_detector.method        
        case 'cnn-from-scratch'
            features = single(features); 
            % replace last layer for a softmax one
            ma_detector.net.layers{end} = struct('type', 'softmax') ; 
        case 'cnn-fine-tune'
            features = single(features); 
            % replace last layer for a softmax one
            ma_detector.net.layers{end} = struct('type', 'softmax') ; 
        otherwise
            if ~isfield(ma_detector, 'net')
                % Normalize features using the mean and standard deviations of the
                % training data
                features = standardizeCols(features, ma_detector.mu, ma_detector.std);
            else
                ma_detector = ma_detector.classifier;
            end
    end
    
    % For each ma candidate
    for j = 1 : length(pxs)

        switch ma_detector.method
           case 'random-forests'
               [scores(j), y_hat] = classRF_predict_probabilities(features(j,:), ma_detector.model);
               y_hat = (y_hat > 0);
           case 'cnn-from-scratch'
               res = vl_simplenn(ma_detector.net, features(:,:,:,j), [], [], ...
                     'Mode', 'test', ...
                     'conserveMemory', true) ;
               net_output = squeeze(gather(res(end).x));
               [~, y_hat] = max(net_output);
               scores(j) = net_output(2,:);
               y_hat = y_hat - 1;
           case 'cnn-fine-tune'
               res = vl_simplenn(ma_detector.net, features(:,:,:,j), [], [], ...
                     'Mode', 'test', ...
                     'conserveMemory', true) ;
               net_output = squeeze(gather(res(end).x));
               [~, y_hat] = max(net_output);
               scores(j) = net_output(2,:);
               y_hat = y_hat - 1;
           otherwise
               % check if it is a MA or not according to the model
               logit_ = ma_detector.w' * cat(2, features(j,:), 1)';
               scores(j) = exp(logit_) / (1 + exp(logit_));
               y_hat = (scores(j) > 0.5);
        end

        ma_segmentation(pxs{j}) = y_hat;
        ma_score_map(pxs{j}) = scores(j);
    end

end