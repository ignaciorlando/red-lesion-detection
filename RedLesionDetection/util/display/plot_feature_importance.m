
%load('C:\_dr_tbme\red-lesions-detection-model\DIARETDB1_train\combined\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\random-forests.mat')
load('C:\_dr_tbme\red-lesions-detection-model\DIARETDB1-ROCh_train\combined\cnn-from-scratch\classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\random-forests.mat')

% Split deep learned and hand crafted features
grouped_features = zeros(length(detector.model.importance), 3);
grouped_features(1:128,1) = detector.model.importance(1:128);
grouped_features(129:128+54,2) = detector.model.importance(129:128+54);
grouped_features(128+54+1:end,3) = detector.model.importance(128+54+1:end);

figure
bar(grouped_features(:,1), 'b');
hold on
bar(grouped_features(:,2), 'r');
hold on
bar(grouped_features(:,3), 'FaceColor', [0, 0.6, 0]);
xlim([1 length(detector.model.importance)-1]);

set(gca, 'XTick', []);
box on
set(gca,'ygrid','on')

legend({'Deep learned features', 'Intensity based features', 'Shape features'});

xlabel('Features');
ylabel('Feature importance');