
root = pwd ;

% add to path all folder and libraries
addpath(genpath(fullfile(root,'ConfigurationFiles'))) ;
addpath(genpath(fullfile(root,'RedLesionDetection'))) ;
addpath(genpath(fullfile(root,'Learning'))) ;
addpath(genpath(fullfile(root,'Scripts'))) ;
addpath(genpath(fullfile(root,'vesselSegmentation'))) ;
addpath(genpath(fullfile(root,'onh-detection'))) ;
addpath(fullfile(root,'Util')) ;
addpath(genpath(fullfile(root,'Util','eval'))) ;
addpath(genpath(fullfile(root,'Util','files'))) ;
addpath(genpath(fullfile(root,'Util','images'))) ;
addpath(genpath(fullfile(root,'Util','labels'))) ;
addpath(genpath(fullfile(root,'Util','vesselCalibre'))) ;
% add external libraries
addpath(fullfile(root,'Util','external')) ;
addpath(genpath(fullfile(root,'Util','external','hline_vline'))) ; % code for vertical line
addpath(genpath(fullfile(root,'Util','external','markSchmidt'))) ; % code for logistic regression
addpath(genpath(fullfile(root,'Util','external','mseb'))) ; % code for nice error bars
addpath(genpath(fullfile(root,'Util','external','alphamask'))) ; % code for nice MAs
addpath(genpath(fullfile(root,'Util','external','RF_Class_C'))) ; % code for random forests
addpath(fullfile(root,'Util','external','vlfeat','toolbox')) ; % code for ROC curves and stuff
addpath(fullfile(root,'Util','external','matconvnet-master', 'matlab')) ; % code for CNN learning
    

% setup vl_feat
vl_setup;
% setup matconvnet
vl_setupnn;

root = vl_rootnn() ;

original_simplenn_filename = fullfile(root, 'matlab', 'simplenn', 'vl_simplenn.m*');
if numel(dir(original_simplenn_filename')) ~= 0
    delete(original_simplenn_filename);
end
    
if numel(dir(fullfile(root, 'matlab', 'mex', 'vl_nnconv.mex*'))) == 0
    % compile MEX files
    vl_compilenn;
end

if numel(dir(fullfile(pwd, 'SORcomplete_mex.mex*'))) == 0
    % compile ranking loss
    mex ./Learning/rankingloss/SORcomplete_mex.c
end
