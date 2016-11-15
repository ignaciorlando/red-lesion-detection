function onscreen(img)
% VERSION 5/1/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% ONSCREEN displays the image on the screen
%   ONSCREEN(IMG) displays
%     IMG - a matrix with values between 0 and 1

colormap('gray'); % set display grayscale
imagesc(img); % display the image
axis image; % make sure the image is in the correct proportion
clear all;