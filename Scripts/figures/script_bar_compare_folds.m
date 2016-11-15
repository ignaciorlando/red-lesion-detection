% Data set name
dataset = 'MESSIDOR';

[ret, hostname] = system('hostname');
hostname = strtrim(lower(hostname));
% Lab computer
if strcmp(hostname, 'orlando-pc')
    % Folder where the features and labels are
    rootFolder = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\drgrading2016paper\results\classification-results';
elseif strcmp(hostname, 'animas')
    % Folder where the features and labels are
    rootFolder = '';
else
    % Folder where the features and labels are
    rootFolder = 'G:\Dropbox\RetinalImaging\Writing\drgrading2016paper\results\classification-results';
end

% Num folds
numFolds = [2 10];

% Features
% WARNING! Features are used for reading folders, remember to include
% filesep if there are different types of the same feature.
featureFilter = logical([ ...
    0 % overfeat-green
    0 % overfeat-original
    1 % overfeat-clahe
    0 % overfeat-c-clahe
    0 % histograms    
]);

featureList;

lims_axis = [0.5 0.75];

% /////////////////////////////////////////////////////////////////////////

figure;
for f = 1 : length(numFolds)

    % Load results
    load(strcat(rootFolder, filesep, strjoin(options.features.tags), filesep, 'results_per_regularizer-', num2str(numFolds(f)), 'folds.mat'));

    subplot(1, length(numFolds), f);
    box on
    grid('on');
    
    values_to_plot = zeros(options.numFolds, length(options.regularizers));
    for k = 1 : length(options.regularizers)

        for i = 1 : options.numFolds

            current_folds = results_per_regularizer{k};
            values_to_plot(i, k) = current_folds{i}.quality;

        end

    end
    % Take the mean values
    mean_values_to_plot = mean(values_to_plot);
    std_values_to_plot = std(values_to_plot);
    % 
    %barweb([neworder{:,2}], subL1_std_reshaped / sqrt(numtrials), [], [], [], [], [], [], colormap, [], 2, [])
    barweb(mean_values_to_plot, std_values_to_plot, [], [], [], [], [], [], colormap, [], 2, []);
    %bar(values_to_plot);
    
        ylim(lims_axis);
    set(gca,'YTick',[lims_axis(1):0.05:lims_axis(2)]) 

end


%set(gca,'XTickLabel',{'MESSIDOR - Fold 1', 'MESSIDOR - Fold 2'})

% legend(options.regularizers, 'Location', 'southeast');
% title(options.features.tags);
