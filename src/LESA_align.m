function varargout = LESA_align(varargin)
% Tool for alignment of direct infusion type mass spectrometry data
% Copyright (c) 2020 Joris Meurs, MSc
% All rights reserved

% Last Modified by GUIDE v2.5 18-Feb-2020 15:41:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LESA_align_OpeningFcn, ...
                   'gui_OutputFcn',  @LESA_align_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before LESA_align is made visible.
function LESA_align_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LESA_align (see VARARGIN)

% Choose default command line output for LESA_align
handles.output = hObject;

% Update handles structure
set(handles.figure1,'Name','LESA Alignment Tool');
handles.processNames = {
    'Validating parameters'
    'Loading files...'
    'Converting files to .mzXML...'
    'Retrieving peak lists...'
    'Get unique peaks...'
    'Removing isotopes...'
    'Remove background...'
    'Generating intensity matrix...'
    'Exporting unfiltered matrix...'
    'Filter and impute matrix...'
    'Exporting filtered matrix....'
    'Finished'
    };
axes(handles.axes1);
set(gca,'XTick',[],'YTick',[]);
rectangle('Position',[0 0 1 1]);

guidata(hObject, handles);

% UIWAIT makes LESA_align wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LESA_align_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in startProcess.
function startProcess_Callback(hObject, eventdata, handles)
% hObject    handle to startProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parameters.minMZ = str2num(get(handles.minMZ,'String'));
parameters.maxMZ = str2num(get(handles.maxMZ,'String'));
parameters.threshold = str2num(get(handles.thresholdInt,'String'));
parameters.tolerance = str2num(get(handles.massTolerance,'String'));
parameters.name = get(handles.fileName,'String');
parameters.polarity = get(handles.polaritySelection,'Value');
parameters.backgroundSpectrum = get(handles.backgroundSpectrum,'String');
axes(handles.axes1)
patch([0 1 1 0],[0 0 1 1],[1 1 1]);
alignMS(parameters,handles);
guidata(hObject, handles);



function thresholdInt_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresholdInt as text
%        str2double(get(hObject,'String')) returns contents of thresholdInt as a double


% --- Executes during object creation, after setting all properties.
function thresholdInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function massTolerance_Callback(hObject, eventdata, handles)
% hObject    handle to massTolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of massTolerance as text
%        str2double(get(hObject,'String')) returns contents of massTolerance as a double


% --- Executes during object creation, after setting all properties.
function massTolerance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to massTolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minMZ_Callback(hObject, eventdata, handles)
% hObject    handle to minMZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minMZ as text
%        str2double(get(hObject,'String')) returns contents of minMZ as a double


% --- Executes during object creation, after setting all properties.
function minMZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minMZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fileName_Callback(hObject, eventdata, handles)
% hObject    handle to fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileName as text
%        str2double(get(hObject,'String')) returns contents of fileName as a double


% --- Executes during object creation, after setting all properties.
function fileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxMZ_Callback(hObject, eventdata, handles)
% hObject    handle to maxMZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxMZ as text
%        str2double(get(hObject,'String')) returns contents of maxMZ as a double


% --- Executes during object creation, after setting all properties.
function maxMZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxMZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in polaritySelection.
function polaritySelection_Callback(hObject, eventdata, handles)
% hObject    handle to polaritySelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns polaritySelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from polaritySelection


% --- Executes during object creation, after setting all properties.
function polaritySelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to polaritySelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function backgroundSpectrum_Callback(hObject, eventdata, handles)
% hObject    handle to backgroundSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of backgroundSpectrum as text
%        str2double(get(hObject,'String')) returns contents of backgroundSpectrum as a double


% --- Executes during object creation, after setting all properties.
function backgroundSpectrum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backgroundSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browseFile.
function browseFile_Callback(hObject, eventdata, handles)
% hObject    handle to browseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile({'*.raw','Thermo RAW Files (.raw)';'*.mzXML','mzXML Files (.mzXML)'});
if isequal(FileName,0)
    return
end
set(handles.backgroundSpectrum,'String',fullfile(PathName,FileName));