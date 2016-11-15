warning('off','all');

[ret, hostname] = system('hostname');
hostname = strtrim(lower(hostname));
% Lab computer
if strcmp(hostname, 'orlando-pc')
    % Root dir where the data sets are located
    rootDatasets = 'C:\_vessels\MESSIDOR\images';
    % Root folder where the results are going to be stored
    rootResults = 'C:\_vessels\MESSIDOR\images';
end

% Datasets names
datasetsNames = {...
    'Base31', ...
    'Base32', ...
    'Base33', ...
    'Base34', ...
    'Base21', ...
    'Base22', ...
    'Base23', ...
    'Base24', ...
    'Base11', ...
    'Base12', ...
    'Base13', ...
    'Base14', ...
};

% Image extension
extension = 'png';

% For each data set
for i = 1 : length(datasetsNames)
    
    datasetsNames{i}
    
    % Get image path
    imagesPath = strcat(rootDatasets, filesep, datasetsNames{i}, filesep, 'images');
    masksPath = strcat(rootDatasets, filesep, datasetsNames{i}, filesep, 'masks');
    % Get results path
    resultsPathImages = strcat(rootResults, filesep, datasetsNames{i}, filesep, 'images');
    resultsPathMasks = strcat(rootResults, filesep, datasetsNames{i}, filesep, 'masks');
    if (exist(resultsPathImages,'dir')==0)
        mkdir(resultsPathImages);
    end
    
    % Retrieve image names...
    imgNames = dir(imagesPath);
    imgNames = {imgNames.name};
    imgNames(strcmp(imgNames, '..')) = [];
    imgNames(strcmp(imgNames, '.')) = [];
    imgNames = removeFileNamesWithExtension(imgNames, 'mat');
    % And retrieve masks names...
    mskNames = dir(masksPath);
    mskNames = {mskNames.name};
    mskNames(strcmp(mskNames, '..')) = [];
    mskNames(strcmp(mskNames, '.')) = [];
    
    % For each image, process it
    for j = 1 : length(imgNames)
       
        % open the image
        I = imread(strcat(imagesPath, filesep, imgNames{j}));
        % apply CLAHE and save
        if (size(I,2)>1440)
            factor = 1440/size(I,2);
            I = imresize(I, factor);
            mask = imread(strcat(masksPath, filesep, mskNames{j}));
            mask = imresize(mask(:,:,1)>0, factor) > 0;
            imwrite(I, strcat(resultsPathImages, filesep, imgNames{j}));
            imwrite(mask, strcat(resultsPathMasks, filesep, mskNames{j}));
        end
        
        
    end
    
end