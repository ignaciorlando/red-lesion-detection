function [resp, resp1, resp2] = BCOSFIRE(image, filter1, filter2)
% Delineation of blood vessels in retinal images based on combination of BCOSFIRE filters responses.
%
% VERSION 09/09/2014
% CREATED BY: George Azzopardi (1), Nicola Strisciuglio (1,2), Mario Vento (2) and Nicolai Petkov (1)
%             1) University of Groningen, Johann Bernoulli Institute for Mathematics and Computer Science, Intelligent Systems
%             1) University of Salerno, Dept. of Information Eng., Electrical Eng. and Applied Math., MIVIA Lab
%
%   If you use this script please cite the following paper:
%   "George Azzopardi, Nicola Strisciuglio, Mario Vento, Nicolai Petkov, 
%   Trainable COSFIRE filters for vessel delineation with application to retinal images, 
%   Medical Image Analysis, Available online 3 September 2014, ISSN 1361-8415, 
%   http://dx.doi.org/10.1016/j.media.2014.08.002"
% 
%   BCOSFIRE achieves orientation selectivity by combining the output - at certain 
%   positions with respect to the center of the COSFIRE filter - of center-on 
%   difference of Gaussians (DoG) functions by a  geometric mean. 
%
%   BCOSFIRE takes as input:
%      image -> RGB retinal fundus image
%      filter1 -> a struct defining the configuration parameters of the
%                 symmetric filter:                   
%                   Name                Value
%                   'sigma'             Value of the standard deviation of
%                                       the outer Gaussian funciton in the DoG
%                   'len'               The length of the filter support
%                   'sigma0'            Value of the standard deviation of
%                                       the Gaussian weigthing function
%                   'alpha'             Alpha coefficient of the weighting
%                                       function
%      filter2 -> a struct defining the configuration parameters of the
%                 asymmetric filter:                   
%                   Name                Value
%                   'sigma'             Value of the standard deviation of
%                                       the outer Gaussian funciton in the DoG
%                   'len'               The length of the filter support
%                   'sigma0'            Value of the standard deviation of
%                                       the Gaussian weigthing function
%                   'alpha'             Alpha coefficient of the weighting
%                                       function
%      preprocessthresh -> a threshold value used in the preprocessing step
%                          (must be a float value in [0, 1])
%      thresh -> threshold value used to threshold the final filter
%                response (must be an integer value in [0, 255])
%
%   BCOSFIRE returns:
%      resp     -> response of the combination of a symmetric and an
%                   asymemtric COSFIRE filters
%      segresp  -> binarized vessel map obtained by performing thresholding
%                   of the final response by a threshold value defined by
%                   "thresh"
%      resp1    -> response of the only BCOSFIRE symmetric filter
%      resp1    -> response of the only BCOSFIRE asymmetric filter
%
%   Example: [resp seg r1 r2] = BCOSFIRE(imread('01_test.tif'), f1, f2, 0.5, 38);
%
%   The image 01_test.tif is taken from the DRIVE data set, which can be 
%   downloaded from: http://www.isi.uu.nl/Research/Databases/DRIVE/

    %% Model configuration
    % Prototype pattern
    x = 101; y = 101; % center
    line1(:, :) = zeros(201);
    line1(:, x) = 1; %prototype line

    % Symmetric filter params
    symmfilter = cell(1);
    symm_params = SystemConfig;
    % COSFIRE params
    symm_params.inputfilter.DoG.sigmalist = filter1.sigma;
    symm_params.COSFIRE.rholist = 0:2:filter1.len;
    symm_params.COSFIRE.sigma0 = filter1.sigma0 / 6;
    symm_params.COSFIRE.alpha = filter1.alpha / 6;
    % Orientations
    numoriens = 12;
    symm_params.invariance.rotation.psilist = 0:pi/numoriens:pi-pi/numoriens;
    % Configuration
    symmfilter{1} = configureCOSFIRE(line1, round([y x]), symm_params);
    % Show the structure of the COSFIRE filter
    % showCOSFIREstructure(symmfilter);

    % Asymmetric filter params
    asymmfilter = cell(1);
    asymm_params = SystemConfig;
    % COSFIRE params
    asymm_params.inputfilter.DoG.sigmalist = filter2.sigma;
    asymm_params.COSFIRE.rholist = 0:2:filter2.len;
    asymm_params.COSFIRE.sigma0 = filter2.sigma0 / 6;
    asymm_params.COSFIRE.alpha = filter2.alpha / 6;
    % Orientations
    numoriens = 24;
    asymm_params.invariance.rotation.psilist = 0:2*pi/numoriens:(2*pi)-(2*pi/numoriens);
    % Configuration
    asymmfilter{1} = configureCOSFIRE(line1, round([y x]), asymm_params);
    asymmfilter{1}.tuples(:, asymmfilter{1}.tuples(4,:) > pi) = []; % Deletion of on side of the filter

    %% Filters application
    image = adapthisteq(image);
    image = 1 - image;

    % Apply the symmetric B-COSFIRE to the input image
    resp1 = applyCOSFIRE(image, symmfilter);
    resp1 = resp1{1};

    % Apply the asymmetric B-COSFIRE to the input image
    resp2 = applyCOSFIRE(image, asymmfilter);
    resp2 = resp2{1};

    % Final response
    resp = resp1 + resp2;
    resp = rescaleImage(resp .* mask, 0, 255);
end



function params = SystemConfig
    % VERSION 09/09/2014
    % CREATED BY: George Azzopardi (1), Nicola Strisciuglio (1,2), Mario Vento (2) and Nicolai Petkov (1)
    %             1) University of Groningen, Johann Bernoulli Institute for Mathematics and Computer Science, Intelligent Systems
    %             1) University of Salerno, Dept. of Information Eng., Electrical Eng. and Applied Math., MIVIA Lab
    %
    % SystemConfig returns a structure of the parameters required by the
    % BCOSFIRE filter

    % Use hashtable
    params.ht                             = 1;

    % The radii list of concentric circles
    params.COSFIRE.rholist                = 0:2:8;

    % Minimum distance between dominant contours lying on the same concentric circle
    params.COSFIRE.eta                    = 150*pi/180;

    % Threshold parameter used to suppress the input filters responses that are less than a
    % fraction t1 of the maximum
    params.COSFIRE.t1                     = 0;

    % Threshold parameter used to select the channels of input filters that
    % produce a response larger than a fraction t2 of the maximum
    params.COSFIRE.t2                     = 0.4;

    % Parameters of the Gaussian function used to blur the input filter
    % responses. sigma = sigma0 + alpha*rho_i
    params.COSFIRE.sigma0                 = 3/6;
    params.COSFIRE.alpha                  = 0.8/6;

    % Parameters used for the computation of the weighted geometric mean. 

    % mintupleweight is the weight assigned to the peripherial contour parts
    params.COSFIRE.mintupleweight         = 0.5;
    params.COSFIRE.outputfunction         = 'geometricmean'; % geometricmean OR weightedgeometricmean 
    params.COSFIRE.blurringfunction       = 'max'; %max or sum

    % Weights are computed from a 1D Gaussian function. weightingsigma is the
    % standard deviation of this Guassian function
    params.COSFIRE.weightingsigma         = sqrt(-max(params.COSFIRE.rholist)^2/(2*log(params.COSFIRE.mintupleweight)));

    % Threshold parameter used to suppress the responses of the COSFIRE filters
    % that are less than a fraction t3 of the maximum response.
    params.COSFIRE.t3                     = 0;

    % % Parameters of some geometric invariances
    numoriens = 12;
    params.invariance.rotation.psilist    = 0:pi/numoriens:(pi)-(pi/numoriens);
    params.invariance.scale.upsilonlist   = 2.^((0)./2);

    % Reflection invariance about the y-axis. 0 = do not use, 1 = use.
    params.invariance.reflection          = 0;

    % Minimum distance allowed between detected keypoints. If the distance
    % between any two pairs of detected keypoints is less than
    % params.distance.mindistance then we keep only the stronger one.
    params.detection.mindistance          = 8;

    % Parameters of the input filter. Here we use symmetric Gabor filters.
    % Gabor filters are, however, not intrinsic to the method and any other
    % filters can be used.
    params.inputfilter.name                     = 'DoG';

    params.inputfilter.Gabor.thetalist          = 0:pi/8:pi-pi/8;
    params.inputfilter.Gabor.lambdalist         = 4.*(sqrt(2).^(0:2));
    params.inputfilter.Gabor.phaseoffset        = pi;
    params.inputfilter.Gabor.halfwaverect       = 0;
    params.inputfilter.Gabor.bandwidth          = 2;
    params.inputfilter.Gabor.aspectratio        = 0.5;
    params.inputfilter.Gabor.inhibition.method  = 1;
    params.inputfilter.Gabor.inhibition.alpha   = 0;
    params.inputfilter.Gabor.thinning           = 0;

    params.inputfilter.DoG.polaritylist         = [1];
    params.inputfilter.DoG.sigmalist            = 2.4;
    params.inputfilter.DoG.sigmaratio           = 0.5;
    params.inputfilter.DoG.halfwaverect         = 0;

    if strcmp(params.inputfilter.name,'Gabor')
        params.inputfilter.symmetric = ismember(params.inputfilter.Gabor.phaseoffset,[0 pi]);
    elseif strcmp(params.inputfilter.name,'DoG')
        params.inputfilter.symmetric = 1;
    end
end