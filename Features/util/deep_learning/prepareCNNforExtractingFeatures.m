
function [new_net] = prepareCNNforExtractingFeatures(net)

    % copy the net
    new_net = net;
    
    % last two layers (fully connected) have to be removed
    to_remove = [];
    % dropout layers as well
    for i = 1 : length(net.layers)-2
        if (strcmp(net.layers{i}.type, 'dropout'))
            to_remove = cat(2, to_remove, i);
        end
    end
    
    % now we remove them
    new_net.layers(to_remove) = [];
    new_net.layers = new_net.layers(1:end-2);

end