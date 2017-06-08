

alpha = 0.01;
min_reference_value = 1/8;
max_reference_value = 8;
number_of_samples = 100;

comparison_curve = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\combined\random-forests\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\ma-froc_data.mat'};
curves_path = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\ma-froc_data.mat', ...
               'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\hand-crafted\random-forests\ma-froc_data.mat'}';
           
% comparison_curve = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\hand-crafted\random-forests\ma-froc_data.mat'};
% curves_path = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\ma-froc_data.mat'}';


% comparison_curve = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\combined\random-forests\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\hemorrhages-froc_data.mat'};
% curves_path = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\hemorrhages-froc_data.mat', ...
%                'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\hand-crafted\random-forests\hemorrhages-froc_data.mat'}';
           
% comparison_curve = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\hand-crafted\random-forests\hemorrhages-froc_data.mat'};
% curves_path = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\combined\random-forests\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\hemorrhages-froc_data.mat'}';           

% comparison_curve = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\combined\random-forests\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\froc_data.mat'};
% curves_path = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\froc_data.mat', ...
%                'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\hand-crafted\random-forests\froc_data.mat', ...
%                'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\froc_data.mat'}';
           
% comparison_curve = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\froc_data.mat'};
% curves_path = {'C:\_dr_tbme\DIARETDB1\test\red-lesions-segmentations\froc_data.mat'}';

% comparison_curve = {'C:\_dr_tbme\e-ophtha\red-lesions-segmentations\combined\random-forests\cnn-from-scratch\classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\froc_data.mat'};
% curves_path = {'C:\_dr_tbme\e-ophtha\red-lesions-segmentations\cnn-from-scratch\classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128\froc_data.mat', ...
%                'C:\_dr_tbme\e-ophtha\red-lesions-segmentations\hand-crafted\random-forests\froc_data.mat'}';