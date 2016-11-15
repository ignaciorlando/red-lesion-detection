function data = evalperformance(contourimage, desiredoutput, invert, perf, mask)
% VERSION 01/08/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% EVALPERFORMANCE: calculates a performance measure based on the comparison
% of the two binary contourmaps (CONTOURIMAGE and DESIREDOUTPUT). The exact
% method is described in [IEEE Transactions on Image Processing, Vol. 12, No. 7, July 2003, p. 733:
% Contour Detection Based on Nonclassical Receptive Field Inhibition, C. Grigorescu, N. Petkov and M.A. Westenberg]
% For each pixel in the CONTOURIMAGE it is checked if there are pixels
% present in a REGIONSIZE x REGIONSIZE region of the DESIREDOUTPUT. If no
% pixels are present, the pixel of the CONTOURIMAGE is marked as false
% positive (FP), if there are pixels present, these are all marked in the
% DESIREDOUTPUT, the pixel in the CONTOURIMAGE is marked as correctly
% detected. After every pixel of the CONTOURIMAGE is checked, it is known
% how many pixels of the CONTOURIMAGE have been correctly detected, the
% number of FP's is also known and finally the number of false negatives is
% defined by counting the non-marked pixels in the DESIREDOUTPUT. 
%   EVALPERFORMANCE(CONTOURIMAGE, DESIREDOUTPUT, INVERT) with the following parameters:
%     CONTOURIMAGE - the black-and-white contourmap (every value >=1 is converted to 1)
%     DESIREDOUTPUT - the binary contourmap which is desired (every value >= middle value is converted to 1)
%     INVERT - if this value is 1, the desiredoutput high and low values
%              should be flipped
%
% PRECONDITION: THE CONTOUR IMAGE SHOULD HAVE THE
% VALUE 1 for FOREGROUND(normally this is interpreted as white lines on a black
% background -- white is 1, black is 0).

% initialise variables
cardE = 0; % number of correctly identified pixels
cardFP = 0; % number of false positives (identified as a 1, though it should have been a 0)
cardFN = 0; % number of false negatives (identified as a 0, though it should have been a 1)
REGIONSIZE = 5; % size of the accepting region, this number should be odd (5x5 is normal)
HREGION = (REGIONSIZE - 1)/2;

% display a progressbar
%h = waitbar(0,'Evaluating performance, please wait ...');

sizeY = size(desiredoutput, 1);
sizeX = size(desiredoutput, 2);

contourimage = (contourimage >= 1)*1; % binary - so set all values above 0 to 1

maxDO = max(max(desiredoutput)); % get the value used for the background (white, highest value)
minDO = min(min(desiredoutput)); % get the value used for the contour (black, lowest value)
middle = round((double(maxDO) + double(minDO)) / 2); % values above middle will be set to 1, others to 0

desiredoutput = (desiredoutput >= middle)*1; % binary

if (invert == 1)
  desiredoutput = (~desiredoutput)*1; % flip values if required
end

% add a border of HREGION rows with zeroes to the desiredoutput (so there can
% be an easy comparison applied in a REGIONSIZE x REGIONSIZE region
desiredoutputL = transpose(padarray(transpose(padarray(desiredoutput, HREGION, 'both')), HREGION, 'both'));
desiredoutputNonMarked = desiredoutputL; % initially all pixels of the desiredoutput are not marked
contourimageTemp = contourimage;
correctdetected = zeros(size(contourimage)); % initialise the correctly detected matrix with zeros

OLD = 1;
NEW = 2;

% returns a one in the matrix if in CONTOURIMAGE and in DESIREDOUTPUT
% exists a 1, otherwise 0 is returned.
for I = -HREGION:HREGION
  for J = -HREGION:HREGION
    % if there exists an edge in the contourimage AND a corresponding pixel
    % in a certain region of the desired outpu (a x a - a is defined by REGIONSIZE) a 1
    % is placed in CI, otherwise a 0 is placed
    
    if perf == OLD
        ci = min((contourimage == desiredoutputL(HREGION+1+I:sizeY+HREGION+I, HREGION+1+J:sizeX+HREGION+J)), (contourimage ~= 0)); 
    elseif perf == NEW
        ci = min((contourimage == desiredoutputNonMarked(HREGION+1+I:sizeY+HREGION+I, HREGION+1+J:sizeX+HREGION+J)), (contourimage ~= 0)); 
    end
    
    % the correctly detected pixels are each step added to the matrix
    % CORRECTDETECTED which stores all correctly detected pixels until now.
    % This matrix consists of 1's (if correctly detected) and 0's (not
    % correctly detected or no pixel in the contourimage present)
    correctdetected = max(ci, correctdetected); 
    
    % if a pixel in the region of the desiredoutput caused the addition of a 1 in CI, this pixel is 
    % marked (e.g. removed from the DESIREDOUTPUTNONMARKED). The unmarked pixels
    % remain as ones (1's) in the array desiredoutputTemp
    desiredoutputNonMarked(HREGION+1+I:sizeY+HREGION+I, HREGION+1+J:sizeX+HREGION+J) = ...
    max(desiredoutputNonMarked(HREGION+1+I:sizeY+HREGION+I, HREGION+1+J:sizeX+HREGION+J) - ci, 0);
  end
end

if nargin == 4
    data.cardE = sum(sum(correctdetected)); % correctly detected pixels
    data.cardFP = sum(sum(contourimage - correctdetected)); % count false positives
    data.cardFN = sum(sum(desiredoutputNonMarked)); % count false negatives
elseif nargin == 5
    data.cardE = sum(sum(correctdetected & mask)); % correctly detected pixels
    data.cardFP = sum(sum((contourimage - correctdetected) & mask)); % count false positives
    sz = size(desiredoutputNonMarked);
    data.cardFN = sum(sum(desiredoutputNonMarked(HREGION+1:sz(1)-HREGION,HREGION+1:sz(2)-HREGION)&mask)); % count false negatives
end    
data.cardTN = prod(size(contourimage)) - data.cardE - data.cardFP - data.cardFN;

%data.match1 = correctdetected;
%data.match2 = desiredoutputL-desiredoutputNonMarked;
data.Recall = data.cardE / (data.cardE + data.cardFN);
data.Precision = data.cardE / (data.cardE + data.cardFP);
data.FMeasure = (2 * data.Precision * data.Recall) /(data.Precision + data.Recall);
data.FMeasure = getFMeasure(data.Precision, data.Recall, 1);
data.FMeasure2 = getFMeasure(data.Precision, data.Recall, 2);
data.FMeasure05 = getFMeasure(data.Precision, data.Recall, 0.5);
%data.Accuracy = data.cardE / (data.cardE + data.cardFP + data.cardFN);

data.Sensitivity = data.cardE / (data.cardE + data.cardFN);
data.Specificity = data.cardTN / (data.cardTN + data.cardFP);
data.Accuracy = (data.cardE + data.cardTN) /(data.cardE + data.cardTN + data.cardFN + data.cardFP);
%waitbar(1); % update the progressbar     
%close(h);

function F = getFMeasure(P,R,beta)

F = ((1 + (beta^2)) * (P * R)) / (((beta^2)*P) + R);