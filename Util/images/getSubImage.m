
function [boxRect] = getSubImage(I, smallSubImage)

    % Get the dimensions of the image.  numberOfColorBands should be = 3.
    [templateHeight, templateWidth, ~] = size(smallSubImage);

    % Ask user which channel (red, green, or blue) to search for a match.
    % channelToCorrelate = menu('Correlate which color channel?', 'Red', 'Green', 'Blue');
    % It actually finds the same location no matter what channel you pick, 
    % for this image anyway, so let's just go with red (channel #1).
    % Note: If you want, you can get the template from every color channel and search for it in every color channel,
    % then take the average of the found locations to get the overall best location.
    channelToCorrelate = 2;  % Use the green channel.
    correlationOutput = normxcorr2(smallSubImage(:,:,channelToCorrelate), I(:,:, channelToCorrelate));
    % Get the dimensions of the image.  numberOfColorBands should be = 1.
    [~, ~, ~] = size(correlationOutput);

    % Find out where the normalized cross correlation image is brightest.
    [~, maxIndex] = max(abs(correlationOutput(:)));
    [yPeak, xPeak] = ind2sub(size(correlationOutput),maxIndex(1));
    % Because cross correlation increases the size of the image, 
    % we need to shift back to find out where it would be in the original image.
    corr_offset = [(xPeak-size(smallSubImage,2)) (yPeak-size(smallSubImage,1))];

    % Calculate the rectangle for the template box.  Rect = [xLeft, yTop, widthInColumns, heightInRows]
    boxRect = [corr_offset(1) corr_offset(2) templateWidth, templateHeight];

end