function varargout = edgedetectiongui(varargin)
% VERSION 05/08/2004
% CREATED BY: M.B. Wieling and N. Petkov, Groningen University,
%             Department of Computer Science, Intelligent Systems
%
% EDGEDETECTIONGUI: creates the graphical user interface for the Contour
% Detection Program (based on non-classical field inhibition). It makes
% sure no illegal values can be entered.
%
% EDGEDETECTIONGUI M-file for edgedetectiongui.fig
%      EDGEDETECTIONGUI, by itself, creates a new EDGEDETECTIONGUI or raises the existing
%      singleton*.
%
%      H = EDGEDETECTIONGUI returns the handle to a new EDGEDETECTIONGUI or the handle to
%      the existing singleton*.
%
%      EDGEDETECTIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDGEDETECTIONGUI.M with the given input arguments.
%
%      EDGEDETECTIONGUI('Property','Value',...) creates a new EDGEDETECTIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before edgedetectiongui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to edgedetectiongui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help edgedetectiongui

% Last Modified by GUIDE v2.5 05-Aug-2004 09:12:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @edgedetectiongui_OpeningFcn, ...
                   'gui_OutputFcn',  @edgedetectiongui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before edgedetectiongui is made visible.
function edgedetectiongui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to edgedetectiongui (see VARARGIN)

% Choose default command line output for edgedetectiongui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using edgedetectiongui.
if strcmp(get(hObject,'Visible'),'off')
   initializeValues(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = edgedetectiongui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Initializes all the values, here also the meaning of all used
% data-variables is explained.
function initializeValues(fig_handle, handles)
  % display initial images
  axes(handles.origImage);
  imagesc(imread(strcat(pwd,'\inputimages\synthetic1.png')));
  axis image;
  axes(handles.convImage);
  imagesc(imread(strcat(pwd,'\inputimages\initimage.png')));
  axis image;
 
  % set all the initial data-variables
  data.imagename=strcat(pwd, '\inputimages\synthetic1.png'); % init. imagename
  data.wavelength=4; % wavelength
  data.orientation=0; % orientation
  data.phaseoffset=[0, 0.5*pi]; % phase offset (0 and 90 degrees)
  data.aspectratio=0.5; % aspectratio
  data.bandwidth=1; % bandwidth
  data.sigma=0; % sigma
  data.nroriens=16; % init number of orientations
  data.hwstate=0; % if this value is 1, than half-wave rectification is applied, otherwise none (checkbox)
  data.halfwave=NaN; % percentage for use with half-wave rectification
  data.halfwave_old=0; % old percentage (if it is unchecked and checked again)
  data.selRight=1; % defines the option which is selected in the display-selection list
  data.inhibMethod=1; % the used inhibition method (1= none, 2 = iso, 3 = aniso)
  data.alpha=1; % alpha, parameter for inhibition
  data.k1=1; % k1, param for inhibition
  data.k2=4; % k2 param for inhibition
  data.facilMethod=1; % if facilitation should be used (1=don't use, 2=use) 
  data.beta=2; % alpha, parameter for facilitation
  data.f1=0.4; % k1, param for facilitation
  data.f2=2; % k2, param for facilitation
  data.power=2; %power, param for facilitation
  data.thinning=0; % if 1 then thinning is applied
  data.hyst=0; % if 1 then hysteresis thresholding is applied
  data.tlow=0.1; % tlow, threshold parameter
  data.thigh=0.2; % thigh, threshold parameter
  data.supPhases=2; % method of phases superposition (1: L1, 2: L2, 3: L-inf, 4: none)
  data.supIsoinhib=3; % method of superposition for isotropic inhibition (1: L1, 2: L2, 3: L-inf)
  data.changeRight=0; % defines if the output image should be displayed
  data.changeLeft=0; % defines if the original image should be reloaded
  data.fastMode=0; % this value makes sure no already available values are recalculated
  data.orienchanged=0; % used to define if in the gui 'Orientation' or 'Number of orientations' is changed => a new orientationlist should be displayed
  data.error=0; % this remembers the errors in the inputvalues (typed in in the GUI)
  data.groundtruth = 'no image selected'; % the filename of the groundtruth
  data.invertGT = 0; % this stores if the groundtruthimage is an inverted version of the output as displayed (black-on-white vs. white-on-black)
  data.performanceValue = NaN; % this stores the performance value
  data.invertOutput = 0; % this stores if a white background should be used (inverting the original result) 
  
  % apply the calculations. fastMode defines a number which
  % defines the speedup, e.g. fastMode == 1: no speedup (all calculations are made), 
  % fastMode == 6: only hysteresis thresholding is calculated.
  if (data.fastMode < 1)
    % initialization and calculation of convolutions
    % note that the list of orientations is sorted and contains no
    % duplicate values
    [data.img, data.orienslist, data.sigmaC] = readandinit(data.imagename, data.orientation, data.nroriens, data.sigma, data.wavelength, data.bandwidth); % initialisation
    data.convResult = gaborfilter(data.img, data.wavelength, data.sigma, data.orienslist, data.phaseoffset, data.aspectratio, data.bandwidth);
    data.oriensdisp = data.orienslist;
    data.selection = (1:size(data.oriensdisp,2)); % the indexes of the orientations which should be calculated
  end
  if (data.fastMode < 2)
    % calculation of half-wave rectification
    data.hwResult = calc_halfwaverect(data.convResult, data.orienslist, data.phaseoffset, data.halfwave);
  end
  if (data.fastMode < 3)
    % calculation of the superposition of phases
    data.superposResult = calc_phasessuppos(data.hwResult, data.orienslist, data.phaseoffset, data.supPhases);
  end
  if (data.fastMode < 4)
    % calculation of the surround inhibition
    data.inhibfacilResult = calc_inhibfacil(data.superposResult, data.inhibMethod, data.supIsoinhib, data.sigmaC, data.alpha, data.k1, data.k2, data.facilMethod, ...
                                            data.beta, data.f1, data.f2, data.orienslist, data.power);
  end
  if (data.fastMode < 5)
    % calculation of the orientationmatrix (maximum orientation response
    % per point) and merges the images per orientation to one image
    [data.viewResult, data.oriensMatrix] = calc_viewimage(data.inhibfacilResult, data.selection, data.orienslist);
  end
  if (data.fastMode < 6)
    % calculation of the thinned image
    data.thinResult = calc_thinning(data.viewResult, data.oriensMatrix, data.thinning);
  end
  if (data.fastMode < 7)
    % calculation of the hysteresis thresholded image
    data.hystResult = calc_hysteresis(data.thinResult, data.hyst, data.tlow, data.thigh);
  end
  data.result = data.hystResult;
  data.fastMode = 8;
  data.disp = 1; % the output-image is displayed (for saving the displayed image)
  
  % create the string of orientations to display in the GUI
  str = num2str(data.oriensdisp(1)*360/(2*pi),4);
  for I = 2:size(data.oriensdisp,2)
    str = [str ', ' num2str(data.oriensdisp(I)*360/(2*pi),4)];
  end
  set(handles.mergelist, 'String', str);
  setappdata(fig_handle, 'metricdata', data);
  % save the parameters which were used for the most recent image
  % display, because when the image is saved and there were new values
  % entered (and 'Update image' was not pressed) incorrect values are 
  % saved in the textfile belonging to the saved image.
  savedispparams(fig_handle); 

  
%%% UPDATE BUTTON
% --- Executes on button press in updatebuttonImConv.
function updatebuttonImConv_Callback(hObject, eventdata, handles)
% hObject    handle to updatebuttonImConv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
checkAndUpdate(handles); % updates the image(s)



% checks and updates the images this method is called whenever the updatebutton is pressed
% also checks and displays an error message if a value is not correct
function checkAndUpdate(handles)
  data = getappdata(gcbf, 'metricdata');
  if not(size(data.error,2) == 1)
    % if not all fields contain legal values, display a corresponding error.
    dispstring = 'Not all fields contain legal values. Please change the following field(s):';
    if (ismember(1,data.error))
      dispstring = strcat(dispstring,'- Wavelength -');
    end
    if (ismember(2,data.error))
      dispstring = strcat(dispstring,'- Orientation(s) -');
    end
    if (ismember(3,data.error))
      dispstring = strcat(dispstring,'- Phase offset(s) -');
    end
    if (ismember(4,data.error))
      dispstring = strcat(dispstring,'- Aspect ratio -');
    end
    if (ismember(5,data.error))
      dispstring = strcat(dispstring,'- Bandwidth -');
    end
    if (ismember(6,data.error))
      dispstring = strcat(dispstring,'- Number of orientations -');
    end
    if (ismember(7,data.error))
      dispstring = strcat(dispstring,'- Imagename -');
    end
    if (ismember(8,data.error))
      dispstring = strcat(dispstring,'- Half-wave rectification -');
    end
    if (ismember(9,data.error))
      dispstring = strcat(dispstring,'- Alpha  -');
    end
    if (ismember(10,data.error))
      dispstring = strcat(dispstring,'- K1 -');
    end
    if (ismember(11,data.error))
      dispstring = strcat(dispstring,'- K2 -');
    end
    if (ismember(12,data.error))
      dispstring = strcat(dispstring,'- K1 or K2  -');
    end
    if (ismember(13,data.error))
      dispstring = strcat(dispstring,'- T-low -');
    end
    if (ismember(14,data.error))
      dispstring = strcat(dispstring,'- T-high -');
    end
    if (ismember(15,data.error))
      dispstring = strcat(dispstring,'- T-low or T-high -');
    end
    if (ismember(16,data.error))
      dispstring = strcat(dispstring,'- Beta -');
    end
    if (ismember(17,data.error))
      dispstring = strcat(dispstring,'- F1 -');
    end
    if (ismember(18,data.error))
      dispstring = strcat(dispstring,'- F2 -');
    end
    if (ismember(19,data.error))
      dispstring = strcat(dispstring,'- F1 or F2 -');
    end
    if (ismember(20,data.error))
      dispstring = strcat(dispstring,'- Power -');
    end
    dispstring = strcat(dispstring,'.');
    errordlg(dispstring, 'Input Error');
  else 
   data = getappdata(gcbf, 'metricdata');   
   data.performanceValue = NaN; % delete the performance measure, because the image has been changed
   setappdata(gcbf, 'metricdata', data); 
   set(handles.performancedisplay, 'String', '');
   % all values are legal - display the filter/inhibitionkernel/superposition image
   if (data.changeRight == 1)  
     axes(handles.convImage);
     % see for explanation of the steps the method 'INITIALIZEVALUES'
     if (data.selRight == 2) % select the output image to be changed
       data = getappdata(gcbf, 'metricdata');
       data.filterresult = filterkernel_onscreen(data.imagename, data.wavelength,0,data.orientation,data.phaseoffset,data.aspectratio,data.bandwidth,data.invertOutput);
       data.disp = 2; % the filter is displayed (for saving the display image)
       setappdata(gcbf, 'metricdata', data); 
     elseif (data.selRight == 3)
       data = getappdata(gcbf, 'metricdata');
       % calculate the sigma
       slratio = (1/pi) * sqrt( (log(2)/2) ) * ( ((2^data.bandwidth)+1) / ((2^data.bandwidth)-1) );
       sigma = slratio * data.wavelength;
       % calculate the inhibitionkernel and display it on screen
       data.inhibresult = inhibkernel_onscreen(data.imagename, sigma, data.k1, data.k2, data.halfwave,data.invertOutput);
       data.disp = 3; % the inhibitionkernel is displayed (for saving the display image)
       setappdata(gcbf, 'metricdata', data);
     elseif (data.selRight == 4)
       data = getappdata(gcbf, 'metricdata');
       % calculate the sigma
       slratio = (1/pi) * sqrt( (log(2)/2) ) * ( ((2^data.bandwidth)+1) / ((2^data.bandwidth)-1) );
       sigma = slratio * data.wavelength;
       % calculate the facilitationkernel and display it on screen
       data.facilresult = facilkernel_onscreen(data.imagename, sigma, data.f1, data.f2, data.halfwave, data.orientation(1), data.power,data.invertOutput);
       data.disp = 4; % the facilitationkernel is displayed (for saving the display image)
       setappdata(gcbf, 'metricdata', data);
     elseif (data.selRight == 5)
       data = getappdata(gcbf, 'metricdata');
       data.filterpowerresult = filterkernelpower_onscreen(data.imagename, data.wavelength,0,data.orientation,data.phaseoffset,data.aspectratio,data.bandwidth,data.invertOutput);
       data.disp = 5; % the filter is displayed (for saving the display image)
       setappdata(gcbf, 'metricdata', data); 
     else % output image
       data = getappdata(gcbf, 'metricdata');
       % apply the calculations. fastMode defines a number which
       % defines the speedup, fastMode == 1: no speedup, fastMode == 6 maximum
       % speedup - only hysteresis thresholding is calculated.
       if (data.fastMode < 1)
          % note that the list of orientations is sorted and contains no
          % duplicate values
         [data.img, data.orienslist, data.sigmaC] = readandinit(data.imagename, data.orientation, data.nroriens, data.sigma, data.wavelength, data.bandwidth); % initialisation
         data.convResult = gaborfilter(data.img, data.wavelength, data.sigma, data.orienslist, data.phaseoffset, data.aspectratio, data.bandwidth);
         if (data.orienchanged == 1)
           % refresh the selected-orientations-display with the new
           % orientations & set the checkbutton back to 'all orientations'
           set(handles.all_radio, 'Value', 1); % set the display back to all orientations
           set(handles.selection_radio, 'Value', 0);
           data.oriensdisp = data.orienslist;
           data.orienchanged = 0;
           data.selection = (1:size(data.oriensdisp,2));
           setappdata(gcbf, 'metricdata', data); 
           disporiensstring(handles); % display the selected orientations
         end  
       end
       if (data.fastMode < 2)
         data.hwResult = calc_halfwaverect(data.convResult, data.orienslist, data.phaseoffset, data.halfwave);
       end
       if (data.fastMode < 3)
         data.superposResult = calc_phasessuppos(data.hwResult, data.orienslist, data.phaseoffset, data.supPhases);
       end
       if (data.fastMode < 4)
          data.inhibfacilResult = calc_inhibfacil(data.superposResult, data.inhibMethod, data.supIsoinhib, data.sigmaC, data.alpha, data.k1, data.k2, data.facilMethod, ...
                                            data.beta, data.f1, data.f2, data.orienslist, data.power);
       end
       if (data.fastMode < 5)
         [data.viewResult, data.oriensMatrix] = calc_viewimage(data.inhibfacilResult, data.selection, data.orienslist);
       end
       if (data.fastMode < 6)
         data.thinResult = calc_thinning(data.viewResult, data.oriensMatrix, data.thinning);
       end
       if (data.fastMode < 7)
         data.hystResult = calc_hysteresis(data.thinResult, data.hyst, data.tlow, data.thigh);
       end
       if (data.fastMode < 8)
         if (data.invertOutput == 1) % the image should be inverted, precondition values between [0..1]
           data.result = 1 - data.hystResult;
         else
           data.result = data.hystResult;
         end
       end
       data.fastMode = 8;
       data.disp = 1; % the output image is displayed (for saving the display image)
       setappdata(gcbf, 'metricdata', data); 
       % display the image on the screen
       onscreen(data.result);   
     end
   end
   data = getappdata(gcbf, 'metricdata');
   data.changeRight = 0;
   setappdata(gcbf, 'metricdata', data); 

   % if a new image was loaded, update the original image
   if (data.changeLeft == 1)
     axes(handles.origImage);
     imagesc(imread(data.imagename));
     axis image;
   end
   data = getappdata(gcbf, 'metricdata');
   data.changeLeft = 0;
   setappdata(gcbf, 'metricdata', data); 
   % save the parameters which were used for the most recent image
   % display, because when the image is saved and there were new values
   % entered (and 'Update image' was not pressed) incorrect values are 
   % saved in the textfile belonging to the saved image.
   savedispparams(gcbf); 
  end
  clear all;

  
% Save all the parameters when the image is saved, so 
% these variables always correspond to values belonging the saved image.
function savedispparams(fig_handle)
data = getappdata(fig_handle, 'metricdata');
data.wavelengthI = data.wavelength;
data.orientationI = data.orientation;
data.phaseoffsetI = data.phaseoffset;
data.aspectratioI = data.aspectratio;
data.bandwidthI = data.bandwidth;
data.nroriensI = data.nroriens;
data.hwstateI = data.hwstate;
data.halfwaveI = data.halfwave;
data.supPhasesI = data.supPhases;
data.inhibMethodI = data.inhibMethod;
data.alphaI = data.alpha;
data.k1I = data.k1;
data.k2I = data.k2;
data.facilMethodI = data.facilMethod;
data.betaI = data.beta;
data.f1I = data.f1;
data.f2I = data.f2;
data.powerI = data.power;
data.supIsoinhibI = data.supIsoinhib;
data.oriensdispI = data.oriensdisp;
data.orienslistI = data.orienslist;
data.thinningI = data.thinning;
data.hystI = data.hyst;
data.tlowI = data.tlow;
data.thighI = data.thigh;
data.selRightI = data.selRight;
data.sigmaCI = data.sigmaC;
data.invertOutputI = data.invertOutput;
setappdata(fig_handle, 'metricdata', data); 
  
  
% The methods below all read the selected/entered values in the GUI.
% Here also the errorchecking is implemented

%%%% GABOR FILTERING
%%% WAVELENGTH - only the steps for this textfield are explained
%%%              for the other textfields the steps are the same
% --- Executes during object creation, after setting all properties.
function wavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function wavelength_Callback(hObject, eventdata, handles)
% hObject    handle to wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wavelength as text
%        str2double(get(hObject,'String')) returns contents of wavelength as a double
data = getappdata(gcbf, 'metricdata'); % load all the inputted data
data.wavelength = str2double(get(hObject,'String')); % update the data concerning this textfield
data.fastMode = 0; % the calculations should be redone from this step on
setappdata(gcbf, 'metricdata', data); % store the data
data = getappdata(gcbf, 'metricdata');
% errorchecking, if an error has occured no calculations are carried out
% until the error is corrected
if (isnan(data.wavelength)) | (data.wavelength <= 0)
  errordlg('Please enter a numerical positive value (larger than 0).', 'Input Error');
  data.error = unique([data.error, 1]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1; % the output image should be updated (the value is correct)
  data.error = setdiff(data.error, 1); 
  setappdata(gcbf, 'metricdata', data);
end


%%% ORIENTATION
% --- Executes during object creation, after setting all properties.
function orientation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function orientation_Callback(hObject, eventdata, handles)
% hObject    handle to orientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orientation as text
%        str2double(get(hObject,'String')) returns contents of orientation as a double
orientation = str2num(get(hObject,'String')); % read a number of values separated by comma's
orientation = orientation / (180/pi); % convert the numbers to radians

data = getappdata(gcbf, 'metricdata');
data.orientation = orientation;
data.fastMode = 0;
setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isempty(data.orientation))
  errordlg('Please enter only numerical values between 0 and 360.', 'Input Error');
  data.error = unique([data.error, 2]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 2);  
  data.orienchanged = 1;
  setappdata(gcbf, 'metricdata', data);
end


%%% PHASE OFFSET
% --- Executes during object creation, after setting all properties.
function phaseoffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phaseoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function phaseoffset_Callback(hObject, eventdata, handles)
% hObject    handle to phaseoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phaseoffset as text
%        str2double(get(hObject,'String')) returns contents of phaseoffset as a double

phaseoffset = str2num(get(hObject,'String')); % read a number of values separated by comma's
phaseoffset = phaseoffset / (180/pi); % convert the numbers to radians

data = getappdata(gcbf, 'metricdata');
data.phaseoffset = phaseoffset;
data.fastMode = 0;
setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isempty(data.phaseoffset));
  errordlg('Please enter only numerical values.', 'Input Error');
  data.error = unique([data.error, 3]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 3); 
  setappdata(gcbf, 'metricdata', data);   
end


%%% ASPECT RATIO
% --- Executes during object creation, after setting all properties.
function aspectratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aspectratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function aspectratio_Callback(hObject, eventdata, handles)
% hObject    handle to aspectratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of aspectratio as text
%        str2double(get(hObject,'String')) returns contents of aspectratio as a double

data = getappdata(gcbf, 'metricdata');
data.aspectratio = str2double(get(hObject,'String'));
data.fastMode = 0;
setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isnan(data.aspectratio)) | (data.aspectratio <= 0)
  errordlg('Please enter a numerical positive value (larger than 0).', 'Input Error');
  data.error = unique([data.error, 4]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 4); 
  setappdata(gcbf, 'metricdata', data);
end


%%% BANDWIDTH
% --- Executes during object creation, after setting all properties.
function bandwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bandwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function bandwidth_Callback(hObject, eventdata, handles)
% hObject    handle to bandwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bandwidth as text
%        str2double(get(hObject,'String')) returns contents of bandwidth as a double
data = getappdata(gcbf, 'metricdata');
data.bandwidth = str2double(get(hObject,'String'));
data.fastMode = 0;
setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isnan(data.bandwidth)) | (data.bandwidth <= 0)
  errordlg('Please enter a numerical positive value (larger than 0).', 'Input Error');
  data.error = unique([data.error, 5]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 5); 
  setappdata(gcbf, 'metricdata', data);

end


%%% NRORIENS
% --- Executes during object creation, after setting all properties.
function nroriens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nroriens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function nroriens_Callback(hObject, eventdata, handles)
% hObject    handle to nroriens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nroriens as text
%        str2double(get(hObject,'String')) returns contents of nroriens as a double
data = getappdata(gcbf, 'metricdata');
data.nroriens = str2double(get(hObject,'String'));
data.fastMode = 0;
setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isnan(data.nroriens)) | (data.nroriens <= 0)
  errordlg('Please enter a numerical positive value (larger than 0).', 'Input Error');
  data.error = unique([data.error, 6]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 6); 
  data.orienchanged = 1;
  setappdata(gcbf, 'metricdata', data); 
end
%%%% END GABOR FILTERING


%%%% HALF-WAVE RECTIFICATION
%%% HALFWAVE CHECKBUTTON
% --- Executes on button press in halfwave_check.
function halfwave_check_Callback(hObject, eventdata, handles)
% hObject    handle to halfwave_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of halfwave_check
data = getappdata(gcbf, 'metricdata');
data.hwstate = get(hObject,'Value');
data.fastMode = min(data.fastMode,1); % if fastMode has a lower value, do not change the value
if (data.hwstate == 1)
  set(handles.halfwave_edit, 'Enable', 'on'); % enable the textfield
  data.halfwave = data.halfwave_old; % set the old value back (the value when the textfield was disabled)
  if (data.halfwave < 0) | (data.halfwave > 100) | (isnan(data.halfwave))
    errordlg('Please enter a valid percentage (only numerical values between 0 and 100).', 'Input Error');
    data.error = unique([data.error, 8]);
  end
else
  set(handles.halfwave_edit, 'Enable', 'off'); % disable the textfield
  data.halfwave_old = data.halfwave;
  data.halfwave = NaN;
  data.error = setdiff(data.error, 8);
end 
data.changeRight = 1;
setappdata(gcbf, 'metricdata', data); 


%%% HALFWAVE PERCENTAGE
% --- Executes during object creation, after setting all properties.
function halfwave_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function halfwave_edit_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold_edit as text
%        str2double(get(hObject,'String')) returns contents of threshold_edit as a double
data = getappdata(gcbf, 'metricdata');
data.fastMode = min(data.fastMode,1);
setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (data.hwstate == 1) % only use the value if the checkbox is enabled
  data.halfwave = str2double(get(hObject,'String'));
  if (data.halfwave < 0) | (data.halfwave > 100) | (isnan(data.halfwave))
    errordlg('Please enter a valid percentage (only numerical values between 0 and 100).', 'Input Error');
    data.error = unique([data.error, 8]);
    setappdata(gcbf, 'metricdata', data);
  else
    data.changeRight = 1;
    data.error = setdiff(data.error, 8);
    setappdata(gcbf, 'metricdata', data); 
  end
end
%%%% END OF HALFWAVE RECTIFICATION


%%%% PHASES-SUPERPOSITION
%%% PHASES POPUP
% --- Executes during object creation, after setting all properties.
function phases_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phases_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in phases_popup.
function phases_popup_Callback(hObject, eventdata, handles)
% hObject    handle to phases_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns phases_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from phases_popup
data = getappdata(gcbf, 'metricdata');
contents = get(hObject,'String');
selPhases = contents{get(hObject,'Value')};
data.fastMode = min(data.fastMode,2);
% determine which option was selected
if (strcmp('L1 norm', selPhases) == 1) 
  data.supPhases = 1;
elseif (strcmp('L2 norm', selPhases) == 1)   
  data.supPhases = 2;
elseif (strcmp('L-infinity norm', selPhases) == 1)
  data.supPhases = 3;
else
  data.supPhases = 4;
end
data.changeRight = 1;
setappdata(gcbf, 'metricdata', data);
%%%% END OF PHASES-SUPERPOSITION


%%%% SURROUND INHIBITION
%%% INHIBITION POPUP
% --- Executes during object creation, after setting all properties.
function inhibition_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inhibition_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in inhibition_popup.
function inhibition_popup_Callback(hObject, eventdata, handles)
% hObject    handle to inhibition_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns inhibition_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from inhibition_popup
data = getappdata(gcbf, 'metricdata');
contents = get(hObject,'String');
isInhibition = contents{get(hObject,'Value')};
data.fastMode = min(data.fastMode,3);
if (strcmp('No surround inhibition', isInhibition) == 1)
  data.inhibMethod = 1;
  set(handles.isoinhib_popup, 'Enable', 'off'); % only for isotropic inhibition the isotropic inhibtion should be enabled
  set(handles.alpha, 'Enable', 'off'); % disable the inhibition parameters
  set(handles.k1, 'Enable', 'off');
  set(handles.k2, 'Enable', 'off');
elseif (strcmp('Isotropic surround inhibition', isInhibition) == 1)
  data.inhibMethod = 2;
  set(handles.isoinhib_popup, 'Enable', 'on');
  set(handles.alpha, 'Enable', 'on');
  set(handles.k1, 'Enable', 'on');
  set(handles.k2, 'Enable', 'on');
else
  data.inhibMethod = 3; % anisotropic surround inhibition
  set(handles.isoinhib_popup, 'Enable', 'off');
  set(handles.alpha, 'Enable', 'on');
  set(handles.k1, 'Enable', 'on');
  set(handles.k2, 'Enable', 'on');
end
data.changeRight = 1;
setappdata(gcbf, 'metricdata', data);


%%% ALPHA
% --- Executes during object creation, after setting all properties.
function alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function alpha_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha_edit as text
%        str2double(get(hObject,'String')) returns contents of alpha_edit as a double
data = getappdata(gcbf, 'metricdata');
data.alpha = str2double(get(hObject,'String'));
data.fastMode = min(data.fastMode,3);

setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isnan(data.alpha))
  errordlg('Please enter a numerical value.', 'Input Error');
  data.error = unique([data.error, 9]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 9); 
  setappdata(gcbf, 'metricdata', data);
end


%%% K1
% --- Executes during object creation, after setting all properties.
function k1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function k1_Callback(hObject, eventdata, handles)
% hObject    handle to k1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of k1_edit as text
%        str2double(get(hObject,'String')) returns contents of k1_edit as a double
data = getappdata(gcbf, 'metricdata');
data.k1 = str2double(get(hObject,'String'));
data.fastMode = min(data.fastMode,3);

setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isnan(data.k1)) | (data.k1 == 0)
  errordlg('Please enter a numerical (non zero) value, which is unequal to K2.', 'Input Error');
  data.error = unique([data.error, 10]);
  setappdata(gcbf, 'metricdata', data);
elseif (data.k1 == data.k2) % k1 should be not equal to k2
  errordlg('Please enter a numerical (non zero) value, which is unequal to K2.', 'Input Error');
  data.error = unique([data.error, 12]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 10); 
  data.error = setdiff(data.error, 12);
  setappdata(gcbf, 'metricdata', data);
end


%%% K2
% --- Executes during object creation, after setting all properties.
function k2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function k2_Callback(hObject, eventdata, handles)
% hObject    handle to k2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of k2_edit as text
%        str2double(get(hObject,'String')) returns contents of k2_edit as a double
data = getappdata(gcbf, 'metricdata');
data.k2 = str2double(get(hObject,'String'));
data.fastMode = min(data.fastMode,3);

setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isnan(data.k2)) | (data.k2 == 0)
  errordlg('Please enter a numerical (non zero) value, which is unequal to K1.', 'Input Error');
  data.error = unique([data.error, 11]);
  setappdata(gcbf, 'metricdata', data);
elseif (data.k1 == data.k2)
  errordlg('Please enter a numerical (non zero) value, which is unequal to K1.', 'Input Error');
  data.error = unique([data.error, 12]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 11); 
  data.error = setdiff(data.error, 12);
  setappdata(gcbf, 'metricdata', data);
end


%%% ISO INHIBITION POPUP
% --- Executes during object creation, after setting all properties.
function isoinhib_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isoinhib_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in isoinhib_popup.
function isoinhib_popup_Callback(hObject, eventdata, handles)
% hObject    handle to isoinhib_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns isoinhib_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from isoinhib_popup
data = getappdata(gcbf, 'metricdata');
contents = get(hObject,'String');
selIsoinhib = contents{get(hObject,'Value')};
data.fastMode = min(data.fastMode,3);
if (strcmp('L1 norm', selIsoinhib) == 1)   
  data.supIsoinhib = 1;
elseif (strcmp('L2 norm', selIsoinhib) == 1)   
  data.supIsoinhib = 2;
else
  data.supIsoinhib = 3;
end
data.changeRight = 1;
setappdata(gcbf, 'metricdata', data);
%%%% END OF SURROUND INHIBITION


%%%% SURROUND FACILITATION
%%% FACILITATION POPUP
% --- Executes during object creation, after setting all properties.
function facilMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to facilMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in facilMethod.
function facilMethod_Callback(hObject, eventdata, handles)
% hObject    handle to facilMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns facilMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from facilMethod
data = getappdata(gcbf, 'metricdata');
contents = get(hObject,'String');
isFacilitation = contents{get(hObject,'Value')};
data.fastMode = min(data.fastMode,3);
if (strcmp('Surround facilitation disabled', isFacilitation) == 1)
  data.facilMethod = 1;
  set(handles.beta, 'Enable', 'off'); % disable the facilitation parameters
  set(handles.f1, 'Enable', 'off');
  set(handles.f2, 'Enable', 'off');
  set(handles.power, 'Enable', 'off');
else
  data.facilMethod = 2; % facilitation enabled
  set(handles.beta, 'Enable', 'on');
  set(handles.f1, 'Enable', 'on');
  set(handles.f2, 'Enable', 'on');
  set(handles.power, 'Enable', 'on');
end
data.changeRight = 1;
setappdata(gcbf, 'metricdata', data);


%%% BETA
% --- Executes during object creation, after setting all properties.
function beta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function beta_Callback(hObject, eventdata, handles)
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beta as text
%        str2double(get(hObject,'String')) returns contents of beta as a double
data = getappdata(gcbf, 'metricdata');
data.beta = str2double(get(hObject,'String'));
data.fastMode = min(data.fastMode,3);

setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isnan(data.beta))
  errordlg('Please enter a numerical value.', 'Input Error');
  data.error = unique([data.error, 16]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 16); 
  setappdata(gcbf, 'metricdata', data);
end


%%% F1
% --- Executes during object creation, after setting all properties.
function f1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function f1_Callback(hObject, eventdata, handles)
% hObject    handle to f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f1 as text
%        str2double(get(hObject,'String')) returns contents of f1 as a double
data = getappdata(gcbf, 'metricdata');
data.f1 = str2double(get(hObject,'String'));
data.fastMode = min(data.fastMode,3);

setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isnan(data.f1)) | (data.f1 == 0)
  errordlg('Please enter a numerical (non zero) value, which is unequal to F2.', 'Input Error');
  data.error = unique([data.error, 17]);
  setappdata(gcbf, 'metricdata', data);
elseif (data.f1 == data.f2) % f1 should be not equal to f2
  errordlg('Please enter a numerical (non zero) value, which is unequal to F2.', 'Input Error');
  data.error = unique([data.error, 19]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 17); 
  data.error = setdiff(data.error, 19);
  setappdata(gcbf, 'metricdata', data);
end


%%% F2
% --- Executes during object creation, after setting all properties.
function f2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function f2_Callback(hObject, eventdata, handles)
% hObject    handle to f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f2 as text
%        str2double(get(hObject,'String')) returns contents of f2 as a double
data = getappdata(gcbf, 'metricdata');
data.f2 = str2double(get(hObject,'String'));
data.fastMode = min(data.fastMode,3);

setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isnan(data.f2)) | (data.f2 == 0)
  errordlg('Please enter a numerical (non zero) value, which is unequal to F1.', 'Input Error');
  data.error = unique([data.error, 18]);
  setappdata(gcbf, 'metricdata', data);
elseif (data.f1 == data.f2)
  errordlg('Please enter a numerical (non zero) value, which is unequal to F1.', 'Input Error');
  data.error = unique([data.error, 19]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 18); 
  data.error = setdiff(data.error, 19);
  setappdata(gcbf, 'metricdata', data);
end


%%% POWER
% --- Executes during object creation, after setting all properties.
function power_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function power_Callback(hObject, eventdata, handles)
% hObject    handle to power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of power as text
%        str2double(get(hObject,'String')) returns contents of power as a double
%%%% END OF SURROUND FACILITATION
data = getappdata(gcbf, 'metricdata');
data.power = str2double(get(hObject,'String'));
data.fastMode = min(data.fastMode,3);

setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (isnan(data.power)) | (data.power < 0)
  errordlg('Please enter a numerical positive value.', 'Input Error');
  data.error = unique([data.error, 20]);
  setappdata(gcbf, 'metricdata', data);
else
  data.changeRight = 1;
  data.error = setdiff(data.error, 20); 
  setappdata(gcbf, 'metricdata', data);
end


%%%% MERGE ORIENTATION-MATRICES
%%% ALL ORIENTATION CHECKBOX
% --- Executes on button press in all_radio.
function all_radio_Callback(hObject, eventdata, handles)
% hObject    handle to all_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all_radio
data = getappdata(gcbf, 'metricdata');
val = get(hObject,'Value');
data.oriensdisp = data.orienslist;
if (val == 1)
   set(handles.selection_radio, 'Value', 0);
else
   set(handles.all_radio, 'Value', 1);
end
data.selection = 1:size(data.oriensdisp,2); % all orientations are selected
data.fastMode = min(data.fastMode, 4);
data.changeRight = 1;
setappdata(gcbf, 'metricdata', data);
disporiensstring(handles);


%%% SELECT ORIENTATIONS BUTTON
% --- Executes on button press in selectoriens_button.
function selectoriens_button_Callback(hObject, eventdata, handles)
% hObject    handle to selectoriens_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = getappdata(gcbf, 'metricdata');
set(handles.selection_radio, 'Value', 1);
set(handles.all_radio, 'Value', 0);
str = num2str(transpose(data.orienslist*360/(2*pi))); % create the string with the orientations
data.selection = listdlg('PromptString','Select orientation(s):',...
                'SelectionMode','multiple',...
                'ListString',str); % store the highlighted selection
if (size(data.selection) == 0) 
  set(handles.all_radio, 'Value', 1); % set the display back to all orientations
  set(handles.selection_radio, 'Value', 0);
  data.oriensdisp = data.orienslist; % list of the orientations which should be displayed
  data.selection = (1:size(data.oriensdisp,2)); % the indexes of the orientations which should be calculated
else
  data.oriensdisp = data.orienslist(data.selection); % update the list of orientations which should be displayed
end
data.fastMode = min(data.fastMode,4);
data.changeRight = 1;
setappdata(gcbf, 'metricdata', data);
disporiensstring(handles);

% --- Executes on button press in selection_radio.
function selection_radio_Callback(hObject, eventdata, handles)
% hObject    handle to selection_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selection_radio


%%% DISPLAY-FIELD OF THE SELECTED ORIENTATIONS
% --- Executes during object creation, after setting all properties.
function mergelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mergelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function mergelist_Callback(hObject, eventdata, handles)
% hObject    handle to mergelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mergelist as text
%        str2double(get(hObject,'String')) returns contents of mergelist as a double


% Creates a nice string to display in the selected orientations display field
function disporiensstring(handles)
data = getappdata(gcbf, 'metricdata');
str = num2str(data.oriensdisp(1)*360/(2*pi),4);
for I = 2:size(data.oriensdisp,2)
  str = [str ', ' num2str(data.oriensdisp(I)*360/(2*pi),4)];
end
set(handles.mergelist, 'String', str);
setappdata(gcbf, 'metricdata', data);
%%%% END OF MERGE SELECTED ORIENTATIONS
  
  
%%%% THRESHOLDING
%%% THINNING
% --- Executes on button press in thinning_check.
function thinning_check_Callback(hObject, eventdata, handles)
% hObject    handle to thinning_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of thinning_check
data = getappdata(gcbf, 'metricdata');
data.thinning = get(hObject,'Value');
data.changeRight = 1;
data.fastMode = min(data.fastMode,5);
setappdata(gcbf, 'metricdata', data); 


%%% HYSTERESIS THRESHOLDING
% --- Executes on button press in hysteresis_check.
function hysteresis_check_Callback(hObject, eventdata, handles)
% hObject    handle to hysteresis_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hysteresis_check
data = getappdata(gcbf, 'metricdata');
data.hyst = get(hObject,'Value');
data.fastMode = min(data.fastMode,6);
if (data.hyst == 1)
  % enable the textfields
  set(handles.tlow, 'Enable', 'on'); 
  set(handles.thigh, 'Enable', 'on');
  if (isnan(data.tlow)) | (data.tlow <= 0) | (data.tlow >= 1) % tlow should be smaller than thigh
    errordlg('Please enter a value larger than 0 and smaller than 1, which is smaller than T-high.', 'Input Error');
    data.error = unique([data.error, 13]);
    setappdata(gcbf, 'metricdata', data);
  elseif (data.tlow >= data.thigh)
    errordlg('Please enter a value larger than 0 and smaller than 1, which is smaller than T-high.', 'Input Error');
    data.error = unique([data.error, 15]);
    setappdata(gcbf, 'metricdata', data);
  end
  if (isnan(data.thigh)) | (data.thigh <= 0) | (data.thigh >= 1)
    errordlg('Please enter a value larger than 0 and smaller than 1, which is larger than T-low.', 'Input Error');
    data.error = unique([data.error, 14]);
    setappdata(gcbf, 'metricdata', data);
  end
else
  set(handles.tlow, 'Enable', 'off');
  set(handles.thigh, 'Enable', 'off');
  data.error = setdiff(data.error, 13);
  data.error = setdiff(data.error, 14);
  data.error = setdiff(data.error, 15);
end 
data.changeRight = 1;
setappdata(gcbf, 'metricdata', data); 


%%% TLOW
% --- Executes during object creation, after setting all properties.
function tlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function tlow_Callback(hObject, eventdata, handles)
% hObject    handle to tlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tlow as text
%        str2double(get(hObject,'String')) returns contents of tlow as a double
data = getappdata(gcbf, 'metricdata');
data.fastMode = min(data.fastMode,6);
setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (data.hyst == 1)
  data.tlow = str2double(get(hObject,'String'));
  if (isnan(data.tlow)) | (data.tlow <= 0) | (data.tlow >= 1)
    errordlg('Please enter a value larger than 0 and smaller than 1, which is smaller than T-high.', 'Input Error');
    data.error = unique([data.error, 13]);
    setappdata(gcbf, 'metricdata', data);
  elseif (data.tlow >= data.thigh)
    errordlg('Please enter a value larger than 0 and smaller than 1, which is smaller than T-high.', 'Input Error');
    data.error = unique([data.error, 15]);
    data.error = setdiff(data.error, 13);
    setappdata(gcbf, 'metricdata', data);
  else
    data.changeRight = 1;
    data.error = setdiff(data.error, 13); 
    data.error = setdiff(data.error, 15);
    setappdata(gcbf, 'metricdata', data);
  end
end


%%% THIGH
% --- Executes during object creation, after setting all properties.
function thigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function thigh_Callback(hObject, eventdata, handles)
% hObject    handle to thigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thigh as text
%        str2double(get(hObject,'String')) returns contents of thigh as a double
data = getappdata(gcbf, 'metricdata');
data.fastMode = min(data.fastMode,6);
setappdata(gcbf, 'metricdata', data);
data = getappdata(gcbf, 'metricdata');
if (data.hyst == 1)
  data.thigh = str2double(get(hObject,'String'));
  if (isnan(data.thigh)) | (data.thigh <= 0) | (data.thigh >= 1)
    errordlg('Please enter a value larger than 0 and smaller than 1, which is larger than T-low.', 'Input Error');
    data.error = unique([data.error, 14]);
    setappdata(gcbf, 'metricdata', data);
  elseif (data.k1 == data.k2)
    errordlg('Please enter a value larger than 0 and smaller than 1, which is larger than T-low.', 'Input Error');
    data.error = unique([data.error, 15]);
    data.error = setdiff(data.error, 14); %%%% WAS 13
    setappdata(gcbf, 'metricdata', data);
  else
    data.changeRight = 1;
    data.error = setdiff(data.error, 14); 
    data.error = setdiff(data.error, 15);
    setappdata(gcbf, 'metricdata', data);
  end
end
%%%% END OF THRESHOLDING


%%%% GENERAL
% RIGHT SELECTION BOX
% --- Executes during object creation, after setting all properties.
function rightpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rightpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in rightpopupmenu.
function rightpopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to rightpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns rightpopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rightpopupmenu
data = getappdata(gcbf, 'metricdata');
contents = get(hObject,'String');
isRight = contents{get(hObject,'Value')};
if (strcmp('Output image', isRight) == 1)
    data.selRight = 1;
    data.whitebg = 0;
    data.fastMode = min(data.fastMode,6);
elseif (strcmp('Filterkernel', isRight) == 1)   
    data.selRight = 2;
elseif (strcmp('Inhibitionkernel', isRight) == 1)
    data.selRight = 3;
elseif (strcmp('Filterkernel (power spectrum)', isRight) == 1)
    data.selRight = 5;
else
    data.selRight = 4;
end
data.changeRight = 1;
setappdata(gcbf, 'metricdata', data);

%%% INVERT OUTPUT CHECKBOX
% --- Executes on button press in invertoutputCheckbox.
function invertoutputCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to invertoutputCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = getappdata(gcbf, 'metricdata');
data.invertOutput = get(hObject,'Value');
data.changeRight = 1;
data.fastMode = min(data.fastMode,7);
setappdata(gcbf, 'metricdata', data); 


%%% SAVEBUTTON
% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% open a file browser with correct extensions
cd OUTPUTIMAGES;
data = getappdata(gcbf, 'metricdata');

postfix = ['.png'; '.bmp'; '.hdf'; '.jpg'; '.pbm'; '.pcx'; '.pgm';  ...
           '.pnm'; '.ppm'; '.ras'; '.tif'; '.xwd'];

[filename, pathname, filterindex] = uiputfile( ...
{'*.png','Portable Network Graphics (*.png)'; ...
 '*.bmp','Windows Bitmap (*.bmp)'; ...
 '*.hdf','Hierarchical Data Format (*.hdf)'; ...
 '*.jpg','JPEG (*.jpg)'; ...
 '*.pbm','Portable Bitmap (*.pbm)'; ...
 '*.pcx','Windows Paintbrush (*.pcx)'; ...
 '*.pgm','Portable Graymap (*.pgm)'; ...
 '*.pnm','Portable Anymap (*.pnm)'; ...
 '*.ppm','Portable Pixmap (*.ppm)'; ...
 '*.ras','Sun Raster (*.ras)'; ...
 '*.tif','Tagged Image File Format (*.tif)'; ...
 '*.xwd','X Windows Dump (*.xwd)'}, ...
 'Save output image as ...');
cd ..;
if (filename ~= 0)
  % when ok is clicked, the image is saved

  pathfile = [pathname filename];
  imgf = ['.bmp'; '.hdf'; '.jpg'; '.pbm'; '.pcx'; '.pgm'; '.png'; ...
          '.pnm'; '.ppm'; '.ras'; '.tif'; '.xwd'];
  imgfl = ['.tiff'; '.jpeg'];

  sizec = 0; % if sizec doesn't get larger than 0, the file is not an image file
  for I = 1:size(imgf,1)
    sizec = max(sizec, size(regexp(pathfile, strcat(strcat('.+', imgf(I,:)), '$'))));
  end
  for I = 1: size(imgfl, 1)
    sizec = max(sizec, size(regexp(pathfile, strcat(strcat('.*', imgfl(I,:)), '$'))));
  end

  % define the displayed image which should be saved
  if (data.disp == 1)
    saveimg = data.result;
  elseif (data.disp == 2)
    saveimg = data.filterresult;
  elseif (data.disp == 3) 
    saveimg = data.inhibresult;
  elseif (data.disp == 5)
    saveimg = data.filterpowerresult;
  else
    saveimg = data.facilresult;
  end
   
  if (sizec > 0) % a correct suffix is contained in the filename
    imwrite(saveimg, [pathname filename]);
    paramswrite(pathname, filename); % write all the parameters to a file
  else
    imwrite(saveimg, [pathname filename postfix(filterindex,:)]); % otherwise include the selected suffix
    paramswrite(pathname, [filename postfix(filterindex,:)]);
  end
end


%%% OPENBUTTON
% --- Executes on button press in openButton.
function openButton_Callback(hObject, eventdata, handles)
% hObject    handle to openButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% open a file browser with the files with correct extensions
cd inputimages;
data = getappdata(gcbf, 'metricdata');
[filename, pathname] = uigetfile( ...
 {'*.jpg; *.jpeg; *.gif; *.png; *.bmp; *.hdf; *.pbm; *.pcx; *.pgm; *.pnm; *.ppm; *.ras; *.tif; *.tiff; *.xwd', 'All Image Files'; ...
  '*.jpg; *.jpeg','JPEG (*.jpg, *.jpeg)'; ...
  '*.gif', 'Graphics Interchange Format (*.gif)'; ...
  '*.png','Portable Network Graphics (*.png)'; ...
  '*.bmp','Windows Bitmap (*.bmp)'; ...
  '*.hdf','Hierarchical Data Format (*.hdf)'; ...
  '*.pbm','Portable Bitmap (*.pbm)'; ...
  '*.pcx','Windows Paintbrush (*.pcx)'; ...
  '*.pgm','Portable Graymap (*.pgm)'; ...
  '*.pnm','Portable Anymap (*.pnm)'; ...
  '*.ppm','Portable Pixmap (*.ppm)'; ...
  '*.ras','Sun Raster (*.ras)'; ...
  '*.tif; *.tiff','Tagged Image File Format (*.tif, *.tiff)'; ...
  '*.xwd','X Windows Dump (*.xwd)'; ...
  '*', 'All Files (*.*)'}, ...
  'Open image ...');
  cd ..;
  if (filename ~= 0)
    % ok is pressed, load the filename
    data.imagename = [pathname filename];
    data.changeLeft = 1; % the left image should be also updated
    data.changeRight = 1;
    data.fastMode = 0;
    setappdata(gcbf, 'metricdata', data);
    checkAndUpdate(handles); % update the image
    %set(handles.inputimagedisplay, 'String', filename);
  end
  
  % --- Executes during object creation, after setting all properties.
function inputimagedisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputimagedisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function inputimagedisplay_Callback(hObject, eventdata, handles)
% hObject    handle to inputimagedisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputimagedisplay as text
%        str2double(get(hObject,'String')) returns contents of inputimagedisplay as a double

  
% Save the values of all parameters belonging to the saved image to a file.
% A specific file is created when the filter- or inhibitionkernel is saved.
function paramswrite(pathname, filename)
% define the name of the savefile by removing the '.' and adding '.txt'
length = size(filename,2);
savefilename = strcat(filename(:,1:length-4), strcat(filename(:,length-2:length), '.txt'));

data = getappdata(gcbf, 'metricdata');
fid = fopen([pathname savefilename], 'w+'); % open the file

% print the values
fprintf(fid, '*********************************************************\n');
fprintf(fid, '*  This file was created on %s        *\n', datestr(now));
fprintf(fid, '*  by the Contour detection demo (version 1.5.040614)   *\n');
fprintf(fid, '*                                                       *\n');
fprintf(fid, '*  The Contour detection demo is designed by:           *\n');
fprintf(fid, '*  M.B. Wieling and N. Petkov, University of Groningen  *\n');
fprintf(fid, '*  Department of Computer Science, Intelligent Systems  *\n'); 
fprintf(fid, '*********************************************************\n\n');

if (data.selRightI == 1) % output image
  if (data.invertOutputI == 1)
    fprintf(fid, 'The generated image (inverted) %s\n', strcat(pathname, filename));
  else
    fprintf(fid, 'The generated image %s\n', strcat(pathname, filename));
  end
  fprintf(fid, 'is based on the following parameters:\n');

  fprintf(fid, '\n*** Original image ***\n');
  fprintf(fid, 'Original image: %s\n', data.imagename);

  fprintf(fid, '\n*** Gabor filtering parameters ***\n');
  fprintf(fid, 'Wavelength: %g\n', data.wavelengthI);
  % format the list of orientations
  str = num2str(data.orientationI(1)*360/(2*pi),4);
  for I = 2:size(data.orientationI,2)
    str = [str ', ' num2str(data.orientationI(I)*360/(2*pi),4)];
  end
  fprintf(fid, 'Orientation(s): %s\n', str);
  % format the list of phase offsets
  str = num2str(data.phaseoffsetI(1)*360/(2*pi),4);
  for I = 2:size(data.phaseoffsetI,2)
    str = [str ', ' num2str(data.phaseoffsetI(I)*360/(2*pi),4)];
  end
  fprintf(fid, 'Phase offset(s): %s\n', str); 
  fprintf(fid, 'Aspect ratio: %g\n', data.aspectratioI);
  fprintf(fid, 'Bandwidth: %g\n', data.bandwidthI);
  if (size(data.orientationI,2) == 1) % nroriens is not ignored
    fprintf(fid, 'Number of orientations: %g\n', data.nroriensI);
  end

  fprintf(fid, '\n*** Half-wave rectification parameters ***\n');
  if (data.hwstateI == 1)
    fprintf(fid, 'Half-wave rectification enabled\n');
    fprintf(fid, 'Half-wave rectification percentage: %g\n', data.halfwaveI); 
  else
    fprintf(fid, 'Half-wave rectification disabled\n'); 
  end

  fprintf(fid, '\n*** Superposition of phases parameters ***\n');
  fprintf(fid, 'Superposition method: ');
  if (data.supPhasesI == 1)
    fprintf(fid, 'L1 norm\n');
  elseif (data.supPhasesI == 2)
    fprintf(fid, 'L2 norm\n');
  elseif (data.supPhasesI == 3)
    fprintf(fid, 'L-infinity norm\n');
  else
    fprintf(fid, 'None\n');
  end

  fprintf(fid, '\n*** Surround inhibition parameters ***\n');
  if (data.inhibMethodI == 1)
    fprintf(fid, 'Surround inhibition disabled\n');
  elseif (data.inhibMethodI == 2)
    fprintf(fid, 'Surround inhibition method: Isotropic\n');
    fprintf(fid, 'Alpha: %g\n', data.alphaI);
    fprintf(fid, 'K1: %g\n', data.k1I);
    fprintf(fid, 'K2: %g\n', data.k2I);
    fprintf(fid, 'Superposition method for the inhibitionterm: ');
    if (data.supIsoinhibI == 1)
      fprintf(fid, 'L1 norm\n');
    elseif (data.supIsoinhibI == 2)
      fprintf(fid, 'L2 norm\n');
    else
      fprintf(fid, 'L-infinity norm\n');
    end
  else
    fprintf(fid, 'Surround inhibition method: Anisotropic\n');
    fprintf(fid, 'Alpha: %g\n', data.alphaI);
    fprintf(fid, 'K1: %g\n', data.k1I);
    fprintf(fid, 'K2: %g\n', data.k2I);
  end

  fprintf(fid, '\n*** Surround facilitation parameters ***\n');
  if (data.facilMethodI == 1)
    fprintf(fid, 'Surround facilitation disabled\n');
  else 
    fprintf(fid, 'Surround facilitation enabled:\n');
    fprintf(fid, 'Beta: %g\n', data.betaI);
    fprintf(fid, 'F1: %g\n', data.f1I);
    fprintf(fid, 'F2: %g\n', data.f2I);
    fprintf(fid, 'Power: %g\n', data.powerI);
  end
  
  fprintf(fid, '\n*** Merging parameters ***\n');
  % create the displaystring
  str = num2str(data.oriensdispI(1)*360/(2*pi),4);
  for I = 2:size(data.oriensdispI,2)
    str = [str ', ' num2str(data.oriensdispI(I)*360/(2*pi),4)];
  end
  if (size(data.oriensdispI,2) == size(data.orienslistI,2))
    fprintf(fid, 'Orientations to merge: All (%s)\n',str);
  else
    fprintf(fid, 'Orientations to merge: Specific (%s)\n',str);
  end

  fprintf(fid, '\n*** Thresholding parameters ***\n');
  if (data.thinningI == 1)
    fprintf(fid, 'Thinning enabled\n');
  else
    fprintf(fid, 'Thinning disabled\n');
  end
  if (data.hystI == 1)
    fprintf(fid, 'Hysteresis thresholding enabled\n');
    fprintf(fid, 'T-low: %g\n', data.tlowI);
    fprintf(fid, 'T-high: %g\n', data.thighI);
  else
    fprintf(fid, 'Hysteresis thresholding disabled\n');
  end
  if ~isnan(data.performanceValue)
    fprintf(fid, '\n*** Performance evaluation parameters ***\n');
    fprintf(fid, 'Performance value: %g\n', data.performanceValue);
    fprintf(fid, 'Groundtruth image: %s\n', data.groundtruth);
    if (data.invertGT == 1)
      fprintf(fid, 'Groundtruth image has black foreground on white background');
    end
  end
elseif (data.selRightI == 2) % filterkernel
  if (data.invertOutputI == 1)
    fprintf(fid, 'The generated filterkernel (inverted) %s\n', strcat(pathname, filename));
  else
    fprintf(fid, 'The generated filterkernel %s\n', strcat(pathname, filename));
  end
  fprintf(fid, 'is based on the following parameters:\n\n');
  fprintf(fid, '- Wavelength: %g\n', data.wavelengthI);
  fprintf(fid, '- Orientation: %s\n', num2str(data.orientationI(1)*360/(2*pi),4));
  fprintf(fid, '- Phase offset: %s\n', num2str(data.phaseoffsetI(1)*360/(2*pi),4)); 
  fprintf(fid, '- Aspect ratio: %g\n', data.aspectratioI);
  fprintf(fid, '- Bandwidth: %g\n', data.bandwidthI);
elseif (data.selRightI == 3) % inhibitionkernel
  if (data.invertOutputI == 1)
    fprintf(fid, 'The generated inhibitionkernel (inverted) %s\n', strcat(pathname, filename));
  else
    fprintf(fid, 'The generated inhibitionkernel %s\n', strcat(pathname, filename));
  end
  fprintf(fid, 'is based on the following parameters:\n\n');
  fprintf(fid, '- Wavelength (used to calculate Sigma): %g\n', data.wavelengthI);
  fprintf(fid, '- Bandwidth (used to calculate Sigma): %g\n', data.bandwidthI);
  fprintf(fid, '- Sigma (calculated): %g\n', data.sigmaCI);
  fprintf(fid, '- K1: %g\n', data.k1I);
  fprintf(fid, '- K2: %g\n', data.k2I);
  if (data.hwstateI == 1)
    fprintf(fid, '- Half-wave rectification percentage: %g\n', data.halfwaveI); 
  end
elseif (data.selRightI == 5) % powerspectrum of filterkernel
  if (data.invertOutputI == 1)
    fprintf(fid, 'The generated powerspectrum of the filterkernel (inverted) %s\n', strcat(pathname, filename));
  else
    fprintf(fid, 'The generated filterkernel (powerspectrum) %s\n', strcat(pathname, filename));
  end
  fprintf(fid, 'is based on the following parameters:\n\n');
  fprintf(fid, '- Wavelength: %g\n', data.wavelengthI);
  fprintf(fid, '- Orientation: %s\n', num2str(data.orientationI(1)*360/(2*pi),4));
  fprintf(fid, '- Phase offset: %s\n', num2str(data.phaseoffsetI(1)*360/(2*pi),4)); 
  fprintf(fid, '- Aspect ratio: %g\n', data.aspectratioI);
  fprintf(fid, '- Bandwidth: %g\n', data.bandwidthI);
else % facilitationkernel
  if (data.invertOutputI == 1)
    fprintf(fid, 'The generated facilitationkernel (inverted) %s\n', strcat(pathname, filename));
  else
    fprintf(fid, 'The generated facilitationkernel %s\n', strcat(pathname, filename));
  end
  fprintf(fid, 'is based on the following parameters:\n\n');
  fprintf(fid, '- Wavelength (used to calculate Sigma): %g\n', data.wavelengthI);
  fprintf(fid, '- Bandwidth (used to calculate Sigma): %g\n', data.bandwidthI);
  fprintf(fid, '- Sigma (calculated): %g\n', data.sigmaCI);
  fprintf(fid, '- Orientation: %s\n', num2str(data.orientationI(1)*360/(2*pi),4));
  fprintf(fid, '- F1: %g\n', data.f1);
  fprintf(fid, '- F2: %g\n', data.f2);
  fprintf(fid, '- Power: %g\n', data.powerI);
  if (data.hwstateI == 1)
    fprintf(fid, '- Half-wave rectification percentage: %g\n', data.halfwaveI); 
  end 
end
fclose(fid);
%%%% END OF GENERAL

%%%% PERFORMANCE EVALUATION
%%% SELECT GROUNDTRUTH AND DISPLAY
% --- Executes on button press in selectGTbutton.
function selectGTbutton_Callback(hObject, eventdata, handles)
% hObject    handle to selectGTbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% open a file browser with the files with correct extensions
cd groundtruth;
data = getappdata(gcbf, 'metricdata');
[filename, pathname] = uigetfile( ...
 {'*.jpg; *.jpeg; *.png; *.bmp; *.hdf; *.pbm; *.pcx; *.pgm; *.pnm; *.ppm; *.ras; *.tif; *.tiff; *.xwd', 'All Image Files'; ...
  '*.jpg; *.jpeg','JPEG (*.jpg, *.jpeg)'; ...
  '*.png','Portable Network Graphics (*.png)'; ...
  '*.bmp','Windows Bitmap (*.bmp)'; ...
  '*.hdf','Hierarchical Data Format (*.hdf)'; ...
  '*.pbm','Portable Bitmap (*.pbm)'; ...
  '*.pcx','Windows Paintbrush (*.pcx)'; ...
  '*.pgm','Portable Graymap (*.pgm)'; ...
  '*.pnm','Portable Anymap (*.pnm)'; ...
  '*.ppm','Portable Pixmap (*.ppm)'; ...
  '*.ras','Sun Raster (*.ras)'; ...
  '*.tif; *.tiff','Tagged Image File Format (*.tif, *.tiff)'; ...
  '*.xwd','X Windows Dump (*.xwd)'; ...
  '*', 'All Files (*.*)'}, ...
  'Open image ...');
  cd ..;
  if (filename ~= 0)
    % ok is pressed, load the filename
    data.groundtruth = [pathname filename];
    data.groundtruthname = filename;
    setappdata(gcbf, 'metricdata', data);
    set(handles.GTnamedisplay, 'String', data.groundtruthname);
  end
  
  % --- Executes during object creation, after setting all properties.
function GTnamedisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GTnamedisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function GTnamedisplay_Callback(hObject, eventdata, handles)
% hObject    handle to GTnamedisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GTnamedisplay as text
%        str2double(get(hObject,'String')) returns contents of GTnamedisplay as a double
  
%%% END OF SELECT GROUNDTRUTH AND DISPLAY

%%% INVERT CHECKBOX
% --- Executes on button press in invertcheckbox.
function invertcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to invertcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of invertcheckbox
data = getappdata(gcbf, 'metricdata');
data.invertGT = get(hObject,'Value');
setappdata(gcbf, 'metricdata', data); 
%%% END OF INVERT CHECKBOX

%%% EVALUATE BUTTON AND PERFORMNANCE DISPLAY
% --- Executes on button press in evaluatebutton.
function evaluatebutton_Callback(hObject, eventdata, handles)
% hObject    handle to evaluatebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = getappdata(gcbf, 'metricdata');
if (strcmp('no image selected', data.groundtruth) ~= 1)
  data.gt = imread(data.groundtruth);
  if (sum(size(data.gt) == size(data.result)) ~= 2) % both dimensions should be the same size
    errordlg('Please use a groundtruth which has the same size as the output image.', 'Input Error');
  else
    data.performanceValue = evalperformance(data.hystResult, data.gt, data.invertGT);
    set(handles.performancedisplay, 'String', data.performanceValue);
    setappdata(gcbf, 'metricdata', data);
  end
else
  errordlg('Please select a groundtruth image first.', 'Input Error');
end

% --- Executes during object creation, after setting all properties.
function performancedisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to performancedisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function performancedisplay_Callback(hObject, eventdata, handles)
% hObject    handle to performancedisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of performancedisplay as text
%        str2double(get(hObject,'String')) returns contents of performancedisplay as a double

%%% END OF EVALUATE BUTTON AND PERFORMNANCE DISPLAY
%%%%% END OF PERFORMANCE EVALUATION