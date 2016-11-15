function [cumulateHere] = cumulateData(cumulateHere, cumulateThis)
    cumulateHere.features = cat(1, cumulateHere.features, cumulateThis.features);
    cumulateHere.pre_bag_features = [cumulateHere.pre_bag_features; cumulateThis.pre_bag_features];
    cumulateHere.indices = cat(2, cumulateHere.indices, cumulateThis.indices);
    cumulateHere.labels = cat(1, cumulateHere.labels, cumulateThis.labels);
end