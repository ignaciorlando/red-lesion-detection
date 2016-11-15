function [result oriensMatrix data filterkernel] = Gabor(img, lambda, aspectratio, bandwidth, orientation, shift, halfwave, supPhases, inhibition, fastmode, thinning)
  
  % set all the initial data-variables  
  oriensMatrix = [];  
  if iscell(orientation)
      data.orientation = cell2mat(orientation);
      data.nroriens = length(data.orientation);
  else
      data.orientation = 0;
      data.nroriens = orientation;
  end
  
  if max(img(:)) > 1
      data.img = double(double(img) ./ 255);
  else
      data.img = double(img);
  end
  data.wavelength=lambda; % wavelength
  data.phaseoffset=shift; % phase offset (0 and 90 degrees)
  data.aspectratio=aspectratio; % aspectratio
  data.bandwidth=bandwidth; % bandwidth
  data.sigma=0; % sigma
  data.hwstate=1; % if this value is 1, than half-wave rectification is applied, otherwise none (checkbox)
  data.halfwave=halfwave; % percentage for use with half-wave rectification
  data.halfwave_old=0; % old percentage (if it is unchecked and checked again)
  data.selRight=2; % defines the option which is selected in the display-selection list
  data.inhibMethod=inhibition.method; % the used inhibition method (1= none, 2 = iso, 3 = aniso)
  data.alpha=inhibition.alpha; % alpha, parameter for inhibition
  data.k1=1; % k1, param for inhibition
  data.k2=4; % k2 param for inhibition
  data.facilMethod=1; % if facilitation should be used (1=don't use, 2=use) 
  data.beta=2; % alpha, parameter for facilitation
  data.f1=0.4; % k1, param for facilitation
  data.f2=2; % k2, param for facilitation
  data.power=2; %power, param for facilitation
  data.thinning=thinning; % if 1 then thinning is applied
  data.hyst=0; % if 1 then hysteresis thresholding is applied
  data.tlow=0.1; % tlow, threshold parameter
  data.thigh=0.2; % thigh, threshold parameter
  data.supPhases=supPhases; % method of phases superposition (1: L1, 2: L2, 3: L-inf, 4: none)
  data.supIsoinhib=3; % method of superposition for isotropic inhibition (1: L1, 2: L2, 3: L-inf)
  data.changeRight=0; % defines if the output image should be displayed
  data.changeLeft=0; % defines if the original image should be reloaded
  data.fastMode=fastmode; % this value makes sure no already available values are recalculated
  data.orienchanged=0; % used to define if in the gui 'Orientation' or 'Number of orientations' is changed => a new orientationlist should be displayed
  data.error=0; % this remembers the errors in the inputvalues (typed in in the GUI)
  data.groundtruth = 'no image selected'; % the filename of the groundtruth
  data.invertGT = 0; % this stores if the groundtruthimage is an inverted version of the output as displayed (black-on-white vs. white-on-black)
  data.performanceValue = NaN; % this stores the performance value
  data.invertOutput = 0; % this stores if a white background should be used (inverting the original result) 

  % apply the calculations. fastMode defines a number which
  % defines the speedup, e.g. fastMode == 6: no speedup (all calculations are made), 

    % initialization and calculation of convolutions
    % note that the list of orientations is sorted and contains no
    % duplicate values
    [data.img, data.orienslist, data.sigmaC] = readandinit(data.img, data.orientation, data.nroriens, data.sigma, data.wavelength, data.bandwidth); % initialisation
    [data.convResult data.filterkernel] = gaborfilter(data.img, data.wavelength, data.sigma, data.orienslist, data.phaseoffset, data.aspectratio, data.bandwidth);
    data.oriensdisp = data.orienslist;
    data.selection = (1:size(data.oriensdisp,2)); % the indexes of the orientations which should be calculated
    result = data.convResult;
    filterkernel = data.filterkernel;

  if (data.fastMode > 0)
    % calculation of half-wave rectification
    data.hwResult = calc_halfwaverect(data.convResult, data.orienslist, data.phaseoffset, data.halfwave);
    result = data.hwResult;
  end
  if (data.fastMode > 1)
    % calculation of the superposition of phases
    data.superposResult = calc_phasessuppos(data.hwResult, data.orienslist, data.phaseoffset, data.supPhases);
    result = data.superposResult;
  end
  if (data.fastMode > 2)
    % calculation of the surround inhibition
    data.inhibfacilResult = calc_inhibfacil(data.superposResult, data.inhibMethod, data.supIsoinhib, data.sigmaC, data.alpha, data.k1, data.k2, data.facilMethod, ...
                                            data.beta, data.f1, data.f2, data.orienslist, data.power);
    result = data.inhibfacilResult;                                        
  end
  if (data.fastMode > 3)
    % calculation of the orientationmatrix (maximum orientation response
    % per point) and merges the images per orientation to one image
    [data.viewResult, data.oriensMatrix] = calc_viewimage(data.inhibfacilResult, data.selection, data.orienslist);
    result = data.viewResult;
  end
  if (data.fastMode > 4)
    % calculation of the thinned image
    data.thinResult = calc_thinning(data.viewResult, data.oriensMatrix, data.thinning);
    result = data.thinResult;
  end
  if (data.fastMode > 5)
    % calculation of the hysteresis thresholded image
    data.hystResult = calc_hysteresis(data.thinResult, data.hyst, data.tlow, data.thigh);
    result = data.hystResult;
  end