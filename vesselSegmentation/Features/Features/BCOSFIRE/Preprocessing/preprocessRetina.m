function [ result, img_mask] = preprocessRetina( img )
    %figure;
    %subplot(221);
    %imagesc(img(:,:,2)); colormap(gray); axis off; axis equal;
    
    [img img_mask] = preprocess(img);
    
    %figure; showim(img);
    
%     se = strel('disk', 1, 8);
%     img = imopen(img, se);
    %figure; showim(img);
    
%     meanfilter = fspecial('average', [3 3]);
%     medImg = conv2(img, meanfilter, 'same');

    medImg = medfilt2(img, [3 3]);

    gaussfilter = fspecial('gaussian', [9 9], 1.8);
    gaussImg = conv2(medImg, gaussfilter, 'same');
    
    meanfilter = fspecial('average', [69 69]);
    imgBack = customConv2(gaussImg, img_mask, meanfilter);
    %subplot(222);
    %imagesc(imgBack.*img_mask); colormap(gray); axis off; axis equal;

    imgEnhanched = img - imgBack;
    imShaded = rescaleImage(imgEnhanched, 0, 255);
    
    %subplot(223);
    %imagesc(imShaded); colormap(gray); axis off; axis equal;
    
    %homogenization
    [freq bins] = imhist(uint8(imShaded), 256);
    [mx ind] = max(freq);
    Gmax = bins(ind);
    
    result = imShaded + 128 - Gmax;
    result(find(result < 0)) = 0;
    result(find(result > 255)) = 255;
    
    %Top-hat transformation
    im_compl = imcomplement(result);
    se = strel('disk', 8, 4);
    opening = imopen(im_compl, se);
    result = im_compl - opening;
    
    %figure; showim(result);
    %result = medfilt2(result, [5 5]);
   
    [ignore result] = getBigimg(result .* img_mask, img_mask);
    %subplot(224);
    %imagesc(result); colormap(gray); axis off; axis equal;


function [bigimg smallimg] = getBigimg(img,mask)
    [sizey, sizex] = size(img);
    
    bigimg = zeros(sizey + 100, sizex + 100);
    bigimg(51:(50+sizey), 51:(50+sizex)) = img;

    bigmask = logical(zeros(sizey + 100, sizex + 100));
    bigmask(51:(50+sizey), (51:50+sizex)) = mask;

    % Creates artificial extension of image.
    bigimg = fakepad(bigimg, bigmask, 5, 10);
    smallimg = bigimg(51:(50+sizey), 51:(50+sizex));

