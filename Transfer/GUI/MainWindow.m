function varargout = MainWindow(varargin)
% MAINWINDOW M-file for MainWindow.fig
%      MAINWINDOW, by itself, creates a new MAINWINDOW or raises the existing
%      singleton*.
%
%      H = MAINWINDOW returns the handle to a new MAINWINDOW or the handle to
%      the existing singleton*.
%
%      MAINWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINWINDOW.M with the given input arguments.
%
%      MAINWINDOW('Property','Value',...) creates a new MAINWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainWindow

% Last Modified by GUIDE v2.5 26-Feb-2012 23:38:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @MainWindow_OutputFcn, ...
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


% --- Executes just before MainWindow is made visible.
function MainWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainWindow (see VARARGIN)

% Choose default command line output for MainWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global gui_properties
global config
gui_properties.active_pos = 1;
gui_properties.active_animal_index = [-1, -1];
gui_properties.handles = handles;

%set(handles.data_directory_text,'String',config.data_directory)
%set_image_table_values()
%set_sample_set(config.sample_set)

% --- Outputs from this function are returned to the command line.
function varargout = MainWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function animal1_selection_text_Callback(hObject, eventdata, handles)
% hObject    handle to animal1_selection_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of animal1_selection_text as text
%        str2double(get(hObject,'String')) returns contents of animal1_selection_text as a double
str2num(get(hObject,'String'))


% --- Executes during object creation, after setting all properties.
function animal1_selection_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to animal1_selection_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function animal2_selection_text_Callback(hObject, eventdata, handles)
% hObject    handle to animal2_selection_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of animal2_selection_text as text
%        str2double(get(hObject,'String')) returns contents of animal2_selection_text as a double


% --- Executes during object creation, after setting all properties.
function animal2_selection_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to animal2_selection_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run_matching_experiment_button.
function run_matching_experiment_button_Callback(hObject, eventdata, handles)



function run_matching_experiment_toggle_Callback(hObject, eventdata, handles)
global gui_properties
%This function will display a matching experiment if able
set_animal_index(gui_properties.active_animal_index(1), 1)


% --- Executes on button press in add_labeled_animals_button.
function add_labeled_animals_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_labeled_animals_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in add_unlabled_animals.
function add_unlabled_animals_Callback(hObject, eventdata, handles)
unlabeled_images_path = uigetdir;
add_images(list_files(unlabeled_images_path,'jpgonly'));



% --- Executes when selected object is changed in animal_selection_panel.
function animal_selection_panel_SelectionChangeFcn(hObject, eventdata, handles)
global gui_properties
gui_properties.active_pos = (gui_properties.active_pos == 1) 
set_animal_index(gui_properties.active_animal_index(1),1)

% --- Executes when selected cell(s) is changed in image_table.
function image_table_CellSelectionCallback(hObject, eventdata, handles)
table_data = get(handles.image_table,'data');
global gui_properties
gui_properties.active_pos = 1;
if get(handles.animal2_radiobutton,'Value')
  gui_properties.active_pos = 2;
end
%If there is data in column 2 automatically run an experiment on the first
%row
if isempty(table_data) | isempty(eventdata.Indices)
  set_animal_index(-1,gui_properties.active_pos)
else
  set_animal_index(table_data{eventdata.Indices(1)},gui_properties.active_pos)
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over add_unlabled_animals.
function add_unlabled_animals_ButtonDownFcn(hObject, eventdata, handles)


function data_directory_text_Callback(hObject, eventdata, handles)
set_data_directory(get(handles.data_directory_text,'String'))

% --- Executes during object creation, after setting all properties.
function data_directory_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_directory_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_data_directory_button.
function select_data_directory_button_Callback(hObject, eventdata, handles)
set_data_directory(uigetdir)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over select_data_directory_button.
function select_data_directory_button_ButtonDownFcn(hObject, eventdata, handles)

function data_directory_text_KeyPressFcn(hObject, eventdata, handles)

function data_directory_text_ButtonDownFcn(hObject, eventdata, handles)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over run_matching_experiment_toggle.
function run_matching_experiment_toggle_ButtonDownFcn(hObject, eventdata, handles)



function sample_set_text_Callback(hObject, eventdata, handles)
set_sample_set(get(hObject,'String'))
% hObject    handle to sample_set_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sample_set_text as text
%        str2double(get(hObject,'String')) returns contents of sample_set_text as a double


% --- Executes during object creation, after setting all properties.
function sample_set_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sample_set_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_configuration_button.
function save_configuration_button_Callback(hObject, eventdata, handles)
save_configuration


% --- Executes on button press in buid_database_button.
function buid_database_button_Callback(hObject, eventdata, handles)
build_database();



function animal_name_text_Callback(hObject, eventdata, handles)
% hObject    handle to animal_name_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of animal_name_text as text
%        str2double(get(hObject,'String')) returns contents of animal_name_text as a double


% --- Executes during object creation, after setting all properties.
function animal_name_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to animal_name_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sighting_text_Callback(hObject, eventdata, handles)
% hObject    handle to sighting_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sighting_text as text
%        str2double(get(hObject,'String')) returns contents of sighting_text as a double


% --- Executes during object creation, after setting all properties.
function sighting_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sighting_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function location_text_Callback(hObject, eventdata, handles)
% hObject    handle to location_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of location_text as text
%        str2double(get(hObject,'String')) returns contents of location_text as a double


% --- Executes during object creation, after setting all properties.
function location_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to location_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lat_text_Callback(hObject, eventdata, handles)
% hObject    handle to lat_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lat_text as text
%        str2double(get(hObject,'String')) returns contents of lat_text as a double


% --- Executes during object creation, after setting all properties.
function lat_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lat_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lon_text_Callback(hObject, eventdata, handles)
% hObject    handle to lon_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lon_text as text
%        str2double(get(hObject,'String')) returns contents of lon_text as a double


% --- Executes during object creation, after setting all properties.
function lon_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lon_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function group_size_text_Callback(hObject, eventdata, handles)
% hObject    handle to group_size_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of group_size_text as text
%        str2double(get(hObject,'String')) returns contents of group_size_text as a double


% --- Executes during object creation, after setting all properties.
function group_size_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to group_size_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function notes_text_Callback(hObject, eventdata, handles)
% hObject    handle to notes_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notes_text as text
%        str2double(get(hObject,'String')) returns contents of notes_text as a double


% --- Executes during object creation, after setting all properties.
function notes_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notes_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_information_but.
function save_information_but_Callback(hObject, eventdata, handles)
global gui_properties
animal_name_text = get(handles.animal_name_text,'String');
sighting_text = get(handles.sighting_text,'String');
location_text = get(handles.location_text,'String');
lat = str2num(get(handles.lat_text,'String'));
lon = str2num(get(handles.lon_text,'String'));
group_size = str2num(get(handles.group_size_text,'String'));
flank_text = get(get(handles.flank_panel,'SelectedObject'),'String');
sex_text = get(get(handles.sex_panel,'SelectedObject'),'String');
photo_quality_text = get(get(handles.photo_quality_panel,'SelectedObject'),'String');
month = str2num(get(handles.month_text,'String'));
day = str2num(get(handles.day_text,'String'));
year = str2num(get(handles.year_text,'String'));
hour = str2num(get(handles.hour_text,'String'));
minute = str2num(get(handles.minute_text,'String'));
notes_text = get(handles.notes_text,'String');
animal_name = get(handles.animal_name_text,'String');

if (isempty(month) || isempty(day) || isempty(year) || isempty(hour) || isempty(minute)) 
   msgbox('Datetime is invalid') 
   return
elseif (~(month > 0 && month <= 12 && hour > 0 && hour <= 24 && day > 0 && day <= 32 && minute >= 0 && minute < 60 ))
   msgbox('Datetime is out of range')
   return
end

if (isempty(lat) || isempty(lon)) 
    msgbox('GPS is invalid')
    return
elseif (~(lat >=-90 && lat <=90 && lon >=-180 && lon <=180))
    msgbox('GSP is out of range')
    return
end

if (isempty(group_size))
   msgbox('Group size invalid') 
   return
end

%Get the image we are saving
i = gui_properties.active_animal_index(gui_properties.active_pos);
set_property(animal_name_text,i,-1,'name');
set_property(sighting_text,i,-1,'sighting_id');
set_property(location_text,i,-1,'location');
set_property(lat,i,-1,'lat');
set_property(lon,i,-1,'lon');
set_property(group_size,i,-1,'group_size');
set_property(flank_text,i,-1,'flank');
set_property(sex_text,i,-1,'sex');
set_property(photo_quality_text,i,-1,'photo_quality');
set_property([year month day hour minute 0],i,-1,'sighting_date');

gt_id = get_gtid_from_name(animal_name_text);
if gt_id == -1
  set_property('new',i,-1,'gt_id');
else
  set_property(gt_id,i,-1,'gt_id');
end



% hObject    handle to save_information_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function minute_text_Callback(hObject, eventdata, handles)
% hObject    handle to minute_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minute_text as text
%        str2double(get(hObject,'String')) returns contents of minute_text as a double


% --- Executes during object creation, after setting all properties.
function minute_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minute_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function day_text_Callback(hObject, eventdata, handles)
% hObject    handle to day_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of day_text as text
%        str2double(get(hObject,'String')) returns contents of day_text as a double


% --- Executes during object creation, after setting all properties.
function day_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to day_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function year_text_Callback(hObject, eventdata, handles)
% hObject    handle to year_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of year_text as text
%        str2double(get(hObject,'String')) returns contents of year_text as a double


% --- Executes during object creation, after setting all properties.
function year_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to year_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hour_text_Callback(hObject, eventdata, handles)
% hObject    handle to hour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hour_text as text
%        str2double(get(hObject,'String')) returns contents of hour_text as a double


% --- Executes during object creation, after setting all properties.
function hour_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function month_text_Callback(hObject, eventdata, handles)
% hObject    handle to month_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of month_text as text
%        str2double(get(hObject,'String')) returns contents of month_text as a double


% --- Executes during object creation, after setting all properties.
function month_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to month_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on animal_name_text and none of its controls.
function animal_name_text_KeyPressFcn(hObject, eventdata, handles)
%Hack because matlab doesn't always update text values
if ~isequal(eventdata.Key,'return')
    import java.awt.Robot;
    import java.awt.event.KeyEvent;
    robot=Robot;
    robot.keyPress(KeyEvent.VK_ENTER);
    pause(0.01)
    robot.keyRelease(KeyEvent.VK_ENTER);
end

animal_name_str = get(handles.animal_name_text,'String')
gt_id = get_gtid_from_name(animal_name_str);
if gt_id == -1
    set(handles.is_in_database_status_text,'String','New Animal');
    set(handles.is_in_database_status_text,'ForegroundColor',[0 0 1]);
else
    set(handles.is_in_database_status_text,'String',['Name in Database. gt_id=' num2str(gt_id)]);
    set(handles.is_in_database_status_text,'ForegroundColor',[1 0 0]);
end
% hObject    handle to animal_name_text (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in find_probable_matches_but.
function find_probable_matches_but_Callback(hObject, eventdata, handles)
'hello'
set_probable_match_table_values()
% hObject    handle to find_probable_matches_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
