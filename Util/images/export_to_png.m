
root_path = 'C:\_diabetic_retinopathy\BossaNova\DR2-images-by-referral\negative';

% -----------------------------------------------------------------
% OPEN IMAGES
% -----------------------------------------------------------------
% Access all the content of the folder
img_names = dir(strcat(root_path));
img_names = {img_names.name};
% Remove .. and . from the list of filenames
img_names(strcmp(img_names, '..')) = [];
img_names(strcmp(img_names, '.')) = [];
% Remove all possible .mat files and then store the filenames in
% the subsets position
img_names = removeFileNamesWithExtension(img_names, 'mat');

for i = 1 : length(img_names)

    I = imread(strcat(root_path, filesep, img_names{i}));
    imwrite(I, fullfile(root_path, filesep, strcat(img_names{i},'.png')));

end