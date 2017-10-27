
root = pwd ;

mkdir('data');

% copy all default configuration files to configuration
if exist('configuration', 'file')==0
    % Create folder
    mkdir('configuration');
    % Copy default configuration files
    copyfile('default_configuration', 'configuration');
end

% add to path all folder and libraries
addpath(genpath(fullfile(root,'configuration'))) ;
addpath(genpath(fullfile(root,'RedLesionDetection'))) ;
addpath(genpath(fullfile(root,'Learning'))) ;
addpath(genpath(fullfile(root,'Scripts'))) ;
addpath(genpath(fullfile(root,'vesselSegmentation'))) ;
addpath(genpath(fullfile(root,'onh-detection'))) ;
addpath(genpath(fullfile(root,'Util'))) ;
addpath(genpath(fullfile(root,'Util','eval'))) ;
addpath(genpath(fullfile(root,'Util','files'))) ;
addpath(genpath(fullfile(root,'Util','images'))) ;
addpath(genpath(fullfile(root,'Util','labels'))) ;

% add external libraries
if exist(fullfile(root,'external'), 'dir')==0
    mkdir(fullfile(root,'external'));
end
addpath(fullfile(root,'external')) ;

% if RF does not exist, show a warning message
if exist(fullfile(root,'external','RF_Class_C'), 'dir')==0
    warning('We could not find RF_Class_C. Please, download the package from here: https://github.com/PetterS/hep-2/tree/master/randomforest-matlab/RF_Class_C');
else
    addpath(genpath(fullfile(root,'external','RF_Class_C'))) ; % code for random forests
    cd external/RF_Class_C
    compile_random_forest;
    cd(root)
end

% if VLFeat does not exist, show a warning message
if exist(fullfile(root,'external','tsne'), 'dir')==0
    warning('We could not find t-SNE. Please, download the package from here: https://lvdmaaten.github.io/tsne/');
else
    addpath(fullfile(root,'external','tsne')) ; % code for t-SNE representations
end

% if VLFeat does not exist, show a warning message
if exist(fullfile(root,'external','vlfeat','toolbox'), 'dir')==0
    warning('We could not find VLFeat. Please, download the package from here: http://www.vlfeat.org/download.html');
else
    addpath(fullfile(root,'external','vlfeat','toolbox')) ; % code for ROC curves and stuff
    % setup vl_feat
    vl_setup;
end

% if gpuDeviceCount > 0
%     vl_compilenn('EnableGpu', true, 'CudaMethod', nvcc, 'EnableDouble', true, 'EnableCudnn', false);
% end
% if Matconvnet does not exist, show a warning message
if exist(fullfile(root,'external','matconvnet-master', 'matlab'))==0
    warning('We could not find Matconvnet. Please, download the package from here: https://github.com/vlfeat/matconvnet/');
else
    addpath(fullfile(root,'external','matconvnet-master', 'matlab')) ; % code for CNN learning
    % setup matconvnet
    vl_setupnn;
    root = vl_rootnn() ;

    original_simplenn_filename = fullfile(root, 'matlab', 'simplenn', 'vl_simplenn.m*');
    if numel(dir(original_simplenn_filename')) ~= 0
        delete(original_simplenn_filename);
    end

    if numel(dir(fullfile(root, 'matlab', 'mex', 'vl_nnconv.mex*'))) == 0
        % compile MEX files
        vl_compilenn('EnableGpu',false);
    end
end
    
