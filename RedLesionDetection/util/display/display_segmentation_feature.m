
I = imread('C:\_dr_tbme\DIARETDB1\train\images\image003.png');
candidates = imread('C:\_dr_tbme\DIARETDB1\train\red-lesions_candidates\image003.gif') > 0;
segm = imresize(imread('C:\_dr_tbme\DIARETDB1\train\segmentations\image003_fccrf.png')>0, size(candidates));

figure, imshow(I);

imshow_red_lesion_prob(I, double(candidates), [0 1 0]);

segm_aux = imcomplement(segm);
imshow_red_lesion_prob(segm_aux, double(candidates), [0 1 0]);

segm_aux_1 = imcomplement(bwareaopen(imcomplement(segm_aux), round(100/536 * size(segm_aux,2))));
imshow_red_lesion_prob(segm_aux_1, double(candidates), [0 1 0]);

segm_aux_2 = imcomplement(imclose(imcomplement(segm_aux_1), strel('disk',2,8)));
imshow_red_lesion_prob(segm_aux_2, double(candidates), [0 1 0]);