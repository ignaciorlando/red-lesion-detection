
dataFolder = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\drgrading2016paper\data';
subsetsNames = {'Base11', 'Base12', 'Base13', 'Base14' ...
    'Base21', 'Base22', 'Base23', 'Base24', ...
    'Base31', 'Base32', 'Base33', 'Base34'};
labels_path = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\drgrading2016paper\data\labels\labels.mat';

ma_area = zeros(1200, 1);
ma_number = zeros(1200, 1);
all_labels = zeros(1200, 1);

load(labels_path);

iterator = 1;
for j = 1 : length(subsetsNames)
    % Generate the features path
    features_path = strcat(dataFolder, filesep, 'features', filesep,'ma',filesep,'area', filesep, subsetsNames{j}, filesep, 'features.mat');
    % Load each feature configuration
    load(features_path);
    % assign features
    ma_area(iterator:iterator+100-1) = features;
    
    % Generate the features path
    features_path = strcat(dataFolder, filesep, 'features', filesep,'ma',filesep,'number', filesep, subsetsNames{j}, filesep, 'features.mat');
    % Load each feature configuration
    load(features_path);
    % assign features
    ma_number(iterator:iterator+100-1) = features;
    
    all_labels(iterator:iterator+100-1) = (labels_messidor{j}.dr > 0);
    iterator = iterator + 100;
end

figure
[tpr, tnr, info_area] = vl_roc(2*double(all_labels)-1, ma_area);  
plot(1-tnr, tpr);
hold on
[tpr, tnr, info_number] = vl_roc(2*double(all_labels)-1, ma_number);  
plot(1-tnr, tpr,'--');
legend({strcat('MA area - AUC=', num2str(info_area.auc)); strcat('MA number - AUC=', num2str(info_number.auc))},'location','southeast');
xlabel('FPR');
ylabel('TPR');
grid on
hold off