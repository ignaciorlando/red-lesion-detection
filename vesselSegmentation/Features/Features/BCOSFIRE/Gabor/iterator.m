function result = iterator
% VERSION 30/04/04
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% uses different parameter values and evaluates the different performances

data.imagename=strcat(pwd, '\inputimages\rino.png');
data.desiredOutputname=strcat(pwd, '\groundtruth\rino_gt_binary.jpg');

desiredOutput = imread(data.desiredOutputname);

data.orientation = 0;
data.nroriens = 16;
data.sigma = 0;
data.bandwidth = 1;
data.aspectratio = 0.5;
data.phaseoffset = [0,0.5*pi];
data.halfwave = NaN; % no half-wave rectification
data.hwstate = 0;
data.supPhases = 2; % L2 norm

data.k1 = 1;
data.k2 = 4;

%data.f1 = 0.4;
%data.f2 = 2.0;

data.thinning = 1; % thinning is applied
data.hyst = 1; % hysteresis thresholding is applied

performance_noinhibnofacil = 0;
performance_aniso = 0;
performance_iso = 0;
performance_isofacil = 0;
performance_noinhibfacil = 0;

for (wavelength = 6:6)
  data.wavelength = wavelength;
  [img, data.orienslist, data.sigmaC] = readandinit(data.imagename, data.orientation, data.nroriens, data.sigma, wavelength, data.bandwidth); % initialisation
  data.oriensdisp = data.orienslist;
  data.selection = (1:size(data.oriensdisp,2)); 
  
  convResult = gaborfilter(img, data.wavelength, data.sigma, data.orienslist, data.phaseoffset, data.aspectratio, data.bandwidth);
  hwResult = calc_halfwaverect(convResult, data.orienslist, data.phaseoffset, data.halfwave);
  superposResult = calc_phasessuppos(hwResult, data.orienslist, data.phaseoffset, data.supPhases);
 
  indexAniso = 1;
  indexIso = 1;
  indexIsoFacil = 1;
  indexNoinhibFacil = 1;
  indexNoinhibNofacil = 1;
  
  for (inhibMethod = 1:3)
    data.inhibMethod = inhibMethod;
    if (data.inhibMethod == 3) % aniso, => no facil 
      data.facilMethod = 1;
      for (alpha = 1:0.5:3)
        data.alpha = alpha;
        inhibfacilResult = calc_inhibfacil(superposResult, data.inhibMethod, 0, data.sigmaC, data.alpha, data.k1, data.k2, data.facilMethod, ...
                                           0, 0, 0, data.orienslist, 0);
        [viewResult, oriensMatrix] = calc_viewimage(inhibfacilResult, data.selection, data.orienslist);
        thinResult = calc_thinning(viewResult, oriensMatrix, data.thinning);
        for (tlow = 0.02:0.01:0.14)
            data.tlow = tlow;
            data.thigh = data.tlow*2;
            calcresult = calc_hysteresis(thinResult, data.hyst, data.tlow, data.thigh);
            data.performanceValue = evalperformance(calcresult, desiredOutput, 1);
            writePerformance(data);
            performance_aniso(indexAniso, data.wavelength-2) = data.performanceValue; % store performance measurements (for each wavelength)
            indexAniso = indexAniso + 1;
        end
      end
    elseif (data.inhibMethod == 2) % iso
      for (supIsoinhib = 3:3) % only l-infinitynorm
        data.supIsoinhib = supIsoinhib;
        for (alpha = 1:0.5:3)
          data.alpha = alpha
          for (facilMethod = 1:2)
            data.facilMethod = facilMethod;
            if (data.facilMethod == 1) % no facilitation
              inhibfacilResult = calc_inhibfacil(superposResult, data.inhibMethod, data.supIsoinhib, data.sigmaC, data.alpha, data.k1, data.k2, data.facilMethod, ...
                                                 0, 0, 0, data.orienslist, 0);
              [viewResult, oriensMatrix] = calc_viewimage(inhibfacilResult, data.selection, data.orienslist);
              thinResult = calc_thinning(viewResult, oriensMatrix, data.thinning);                               
              for (tlow = 0.02:0.01:0.14)
                data.tlow = tlow;
                data.thigh = data.tlow*2;
                calcresult = calc_hysteresis(thinResult, data.hyst, data.tlow, data.thigh);
                data.performanceValue = evalperformance(calcresult, desiredOutput, 1);
                writePerformance(data);
                performance_iso(indexIso, data.wavelength-2) = data.performanceValue;
                indexIso = indexIso + 1;
              end
            else
              for (beta = 1:0.5:2.5)
                data.beta = beta
                for (f1 = 0.2:0.2:0.6) %(f1 = 0.2:0.2:0.6)
                  data.f1 = f1;
                  for (f2 = 2.0:0.5:3.0) %(f2 = 2.0:0.5:3.0)
                    data.f2 = f2;
                    for (power = 1:4)
                      data.power = power;
                      inhibfacilResult = calc_inhibfacil(superposResult, data.inhibMethod, data.supIsoinhib, data.sigmaC, data.alpha, data.k1, data.k2, data.facilMethod, ...
                                                         data.beta, data.f1, data.f2, data.orienslist, data.power);
                      [viewResult, oriensMatrix] = calc_viewimage(inhibfacilResult, data.selection, data.orienslist);
                      thinResult = calc_thinning(viewResult, oriensMatrix, data.thinning);
                      for (tlow = 0.02:0.01:0.14)
                        data.tlow = tlow;
                        data.thigh = data.tlow*2;
                        calcresult = calc_hysteresis(thinResult, data.hyst, data.tlow, data.thigh);
                        data.performanceValue = evalperformance(calcresult, desiredOutput, 1);
                        writePerformance(data);
                        performance_isofacil(indexIsoFacil, data.wavelength-2) = data.performanceValue;
                        indexIsoFacil = indexIsoFacil + 1;
                      end
                    end
                  end
                end
              end
            end % if
          end
        end
      end
    else % no inhibition  
      for (facilMethod = 1:2)
        data.facilMethod = facilMethod;
        if (data.facilMethod == 1) % no facilitation
          inhibfacilResult = calc_inhibfacil(superposResult, data.inhibMethod, 0, data.sigmaC, 0, 0, 0, data.facilMethod, ...
                                             0, 0, 0, data.orienslist, 0);
          [viewResult, oriensMatrix] = calc_viewimage(inhibfacilResult, data.selection, data.orienslist);
          thinResult = calc_thinning(viewResult, oriensMatrix, data.thinning);                               
          for (tlow = 0.02:0.01:0.14)
            data.tlow = tlow;
            data.thigh = data.tlow*2;;
            calcresult = calc_hysteresis(thinResult, data.hyst, data.tlow, data.thigh);
            data.performanceValue = evalperformance(calcresult, desiredOutput, 1);
            writePerformance(data);
            performance_noinhibnofacil(indexNoinhibNofacil, data.wavelength-2) = data.performanceValue;
            indexNoinhibNofacil = indexNoinhibNofacil + 1;
          end
        else 
          for (beta = 2:1:5)
            data.beta = beta;
            for (f1 = 0.4:0.4)
              data.f1 = f1;
              for (f2 = 2.0:2.0)
                data.f2 = f2;
                for (power = 1:4)
                  data.power = power;
                  inhibfacilResult = calc_inhibfacil(superposResult, data.inhibMethod, 0, data.sigmaC, 0, 0, 0, data.facilMethod, ...
                                                     data.beta, data.f1, data.f2, data.orienslist, data.power);
                  [viewResult, oriensMatrix] = calc_viewimage(inhibfacilResult, data.selection, data.orienslist);
                  thinResult = calc_thinning(viewResult, oriensMatrix, data.thinning);
                  for (tlow = 0.02:0.01:0.14)
                    data.tlow = tlow;
                    data.thigh = data.tlow*2;
                    calcresult = calc_hysteresis(thinResult, data.hyst, data.tlow, data.thigh);
                    data.performanceValue = evalperformance(calcresult, desiredOutput, 1);
                    writePerformance(data);
                    performance_noinhibfacil(indexNoinhibFacil, data.wavelength-2) = data.performanceValue;
                    indexNoinhibFacil = indexNoinhibFacil + 1;
                  end
                end
              end
            end
          end
        end % if
      end
    end % if - type of inhibition
  end % for - inhibmethod
end % for - wavelength  

% print max. performance
maxperf_noinhibnofacil = max(max(performance_noinhibnofacil)) 
maxperf_aniso = max(max(performance_aniso))
maxperf_isonofacil = max(max(performance_iso)) 
maxperf_isofacil = max(max(performance_isofacil)) 
maxperf_noinhibfacil = max(max(performance_noinhibfacil)) 

% store performance
save 'performance.mat' performance_noinhibfacil performance_aniso performance_isofacil performance_iso performance_aniso performance_noinhibnofacil;


% hier nog een methode om alle waarden (kort op te schrijven in een file). 
function writePerformance(data);

% Save the values of all parameters belonging to the saved image to a file.
% A specific file is created when the filter- or inhibitionkernel is saved.

% define the name of the savefile by removing the '.' and adding '.txt'
cd performance

savefilename = sprintf('results_wavelength%d_inhibmethod%d.txt', data.wavelength, data.inhibMethod);
fid = fopen(savefilename, 'a+'); % open the file

% print the values
fprintf(fid, '*********************************************************\n');

fprintf(fid, 'P: %g\n', data.performanceValue);

% fprintf(fid, '\n*** Comparison images ***\n');
% fprintf(fid, 'Original image: %s\n', data.imagename);
% fprintf(fid, 'Desired output: %s\n', data.desiredOutputname);

% fprintf(fid, '\n*** Gabor filtering parameters ***\n');
fprintf(fid, 'Wavelength: %g\n', data.wavelength);
% format the list of orientations
% str = num2str(data.orientation(1)*360/(2*pi),4);
% for I = 2:size(data.orientation,2)
%   str = [str ', ' num2str(data.orientation(I)*360/(2*pi),4)];
% end
% fprintf(fid, 'Orientation(s): %s\n', str);
% % format the list of phase offsets
% str = num2str(data.phaseoffset(1),4);
% for I = 2:size(data.phaseoffset,2)
%   str = [str ', ' num2str(data.phaseoffset(I),4)];
% end
% fprintf(fid, 'Phase offset(s): %s\n', str); 
% fprintf(fid, 'Aspect ratio: %g\n', data.aspectratio);
% fprintf(fid, 'Bandwidth: %g\n', data.bandwidth);
% if (size(data.orientation,2) == 1) % nroriens is not ignored
%   fprintf(fid, 'Number of orientations: %g\n', data.nroriens);
% end

% fprintf(fid, '\n*** Half-wave rectification parameters ***\n');
% if (data.hwstate == 1)
%   fprintf(fid, 'Half-wave rectification enabled\n');
%   fprintf(fid, 'Half-wave rectification percentage: %g\n', data.halfwave); 
% else
%   fprintf(fid, 'Half-wave rectification disabled\n'); 
% end

% fprintf(fid, '\n*** Superposition of phases parameters ***\n');
% fprintf(fid, 'Superposition method: ');
% if (data.supPhases == 1)
%   fprintf(fid, 'L1 norm\n');
% elseif (data.supPhases == 2)
%   fprintf(fid, 'L2 norm\n');
% elseif (data.supPhases == 3)
%   fprintf(fid, 'L-infinity norm\n');
% else
%   fprintf(fid, 'None\n');
% end

% fprintf(fid, '\n*** Surround inhibition parameters ***\n');
if (data.inhibMethod == 1)
  fprintf(fid, 'Surround inhibition disabled\n');
elseif (data.inhibMethod == 2)
  fprintf(fid, 'Surround inhibition method: Isotropic\n');
  fprintf(fid, 'Alpha: %g\n', data.alpha);
%   fprintf(fid, 'K1: %g\n', data.k1);
%   fprintf(fid, 'K2: %g\n', data.k2);
%   fprintf(fid, 'Superposition method for the inhibitionterm: ');
%   if (data.supIsoinhib == 1)
%     fprintf(fid, 'L1 norm\n');
%   elseif (data.supIsoinhib == 2)
%     fprintf(fid, 'L2 norm\n');
%   else
%     fprintf(fid, 'L-infinity norm\n');
%   end
else
  fprintf(fid, 'Surround inhibition method: Anisotropic\n');
  fprintf(fid, 'Alpha: %g\n', data.alpha);
%   fprintf(fid, 'K1: %g\n', data.k1);
%   fprintf(fid, 'K2: %g\n', data.k2);
end

% fprintf(fid, '\n*** Surround facilitation parameters ***\n');
if (data.facilMethod == 1)
  fprintf(fid, 'Surround facilitation disabled\n');
else 
  fprintf(fid, 'Surround facilitation enabled:\n');
  fprintf(fid, 'Beta: %g\n', data.beta);
  fprintf(fid, 'F1: %g\n', data.f1);
  fprintf(fid, 'F2: %g\n', data.f2);
  fprintf(fid, 'Power: %g\n', data.power);
end
  
% fprintf(fid, '\n*** Thresholding parameters ***\n');
% if (data.thinning == 1)
%   fprintf(fid, 'Thinning enabled\n');
% else
%   fprintf(fid, 'Thinning disabled\n');
% end
if (data.hyst == 1)
  fprintf(fid, 'Hysteresis thresholding enabled\n');
  fprintf(fid, 'T-low: %g\n', data.tlow);
  fprintf(fid, 'T-high: %g\n\n', data.thigh);
else
  fprintf(fid, 'Hysteresis thresholding disabled\n\n');
end
fclose(fid);
cd ..