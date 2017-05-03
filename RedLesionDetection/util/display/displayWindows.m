
%load('C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\drscreening2016paper\data\DIARETDB1-ROCh\train\ma_candidates_data\imdb-red-lesions-windows-ma-augmented.mat');
%load('C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\drscreening2016paper\data\DIARETDB1-ROCh\train\ma_candidates_data\imdb-red-lesions-windows-ma.mat');
%load('/Users/ignaciorlando/Dropbox/RetinalImaging/Writing/drscreening2016paper/data/e-ophtha/ma_candidates_data/imdb-red-lesions-windows-ma.mat');
%load('/Users/ignaciorlando/Dropbox/RetinalImaging/Writing/drscreening2016paper/data/DIARETDB1/train/red-lesions_candidates_data/imdb-red-lesions-windows-red-lesions.mat');

load('C:\_dr_tbme\DIARETDB1\train\red-lesions_candidates_data\imdb-red-lesions-windows-red-lesions-augmented.mat');

different_labels = unique(imdb.images.labels);

%figure
for lbl = 1 : length(different_labels)

    current_labels = find(imdb.images.labels==different_labels(lbl));
    current_images = imdb.images.data(:,:,:,current_labels(randperm(length(current_labels),200)));
    
    figure, vl_imarray(uint8(current_images), 'Layout', [10 20]);
    axis equal ;
    title(sprintf('Label = %d', lbl-1));
    
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    box off

end

