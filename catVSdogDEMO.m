function varargout = catVSdogDEMO(varargin)
% CATVSDOGDEMO MATLAB code for catVSdogDEMO.fig
%      CATVSDOGDEMO, by itself, creates a new CATVSDOGDEMO or raises the existing
%      singleton*.
%
%      H = CATVSDOGDEMO returns the handle to a new CATVSDOGDEMO or the handle to
%      the existing singleton*.
%
%      CATVSDOGDEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CATVSDOGDEMO.M with the given input arguments.
%
%      CATVSDOGDEMO('Property','Value',...) creates a new CATVSDOGDEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before catVSdogDEMO_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to catVSdogDEMO_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above edit1 to modify the response to help catVSdogDEMO

% Last Modified by GUIDE v2.5 19-Jul-2018 10:58:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @catVSdogDEMO_OpeningFcn, ...
                   'gui_OutputFcn',  @catVSdogDEMO_OutputFcn, ...
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


% --- Executes just before catVSdogDEMO is made visible.
function catVSdogDEMO_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to catVSdogDEMO (see VARARGIN)

% Choose default command line output for catVSdogDEMO
handles.output = hObject ;
set(handles.open, 'Enable', 'off') ;
set(handles.rec, 'Enable', 'off') ;
run C:\Matlablib\MatConvNet\matlab\vl_setupnn ;

%加载预训练模型，更新格式
load('.\fineTuningNet.mat') ;
net = vl_simplenn_tidy(net) ;
net.layers{end}.type = 'softmax' ;
handles.net = net;

set(handles.open, 'Enable', 'on') ;

% Update handles structure
guidata(hObject, handles) ;

% UIWAIT makes catVSdogDEMO wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = catVSdogDEMO_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in open.
function open_Callback(hObject, eventdata, handles)
% hObject    handle to open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = uigetfile('.jpg', '请选择图片') ;
handles.fpath = filename ;
image = imread(handles.fpath) ;
axes(handles.axes1) ;
imshow(image) ;
set(handles.rec, 'Enable', 'on') ;
guidata(hObject, handles) ;


% --- Executes on button press in rec.
function rec_Callback(hObject, eventdata, handles)
% hObject    handle to rec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = imread(handles.fpath) ;
im_ = imresize(im, handles.net.meta.inputSize(1:2)) ;
im_ = single(im_) ; 
% im_ = im_ - net.meta.normalization.averageImage ;
res = vl_simplenn(handles.net, im_) ;

scores = squeeze(gather(res(end).x)) ;
[bestScore, best] = max(scores) ;
%disp([bestScore, best]);
handles.result = [bestScore, best] ;
guidata(hObject, handles) ;
set(handles.edit1, 'string', sprintf('这是一只%s, 得分为 %.3f',...
                                      handles.net.meta.classes{handles.result(2)}, ...
                                      handles.result(1))) ;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as edit1
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
