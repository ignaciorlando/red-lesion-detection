
clear
clc 
close all

% RED LESION DETECTION - DIARETDB1
root_path = '/Users/ignaciorlando/Dropbox/RetinalImaging/Writing/drscreening2016paper/results/Lesion segmentation/75% confidence/red-lesions_segmentations/DIARETDB1_test';
list_of_files_to_plot = {'combined/random-forests/cnn-from-scratch/softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.05-fc=128/froc_data.mat', ...
                         'hand-crafted/random-forests/froc_data.mat', ...
                         'cnn-from-scratch/softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.05-fc=128/froc_data.mat'};
filename = 'red-lesions-diaretdb1';

% % MA DETECTION - DIARETDB1
% root_path = '/Users/ignaciorlando/Dropbox/RetinalImaging/Writing/drscreening2016paper/results/Lesion segmentation/75% confidence/ma_segmentations/e-ophtha';
% list_of_files_to_plot = {'combined/random-forests/cnn-from-scratch/classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128/froc_data.mat', ...
%                          'hand-crafted/random-forests/froc_data.mat', ...
%                          'cnn-from-scratch/classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128/froc_data.mat'};
% filename = 'ma-e-ophtha';


tags = {'CNN + hand crafted features', ...
        'Hand crafted features', ...
        'CNN' ...
        };
    
curve_format = {''};

legends_to_show = cell(length(list_of_files_to_plot), 1);

for i = 1 : length(list_of_files_to_plot)
    
    % load the file
    load(fullfile(root_path, list_of_files_to_plot{i})); 
    % plot current numbers
    plot_froc(per_lesion_sensitivity, fpi);
    hold on
    % the legend for this curve will be the tag followed by the froc score
    legends_to_show{i} = [tags{i}, ' - CPM = ', sprintf('%.4f', froc_score)];
    
end

legend(legends_to_show, 'Location', 'northwest');

print(fullfile('/Users/ignaciorlando/Desktop', strcat(filename, '.pdf')),'-dpdf');