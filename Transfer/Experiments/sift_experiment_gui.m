function varargout = sift_experiment_gui(varargin)
% SIFT_EXPERIMENT_GUI M-file for sift_experiment_gui.fig
%      SIFT_EXPERIMENT_GUI, by itself, creates a new SIFT_EXPERIMENT_GUI or raises the existing
%      singleton*.
%
%      H = SIFT_EXPERIMENT_GUI returns the handle to a new SIFT_EXPERIMENT_GUI or the handle to
%      the existing singleton*.
%
%      SIFT_EXPERIMENT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIFT_EXPERIMENT_GUI.M with the given input arguments.
%
%      SIFT_EXPERIMENT_GUI('Property','Value',...) creates a new SIFT_EXPERIMENT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sift_experiment_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sift_experiment_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sift_experiment_gui

% Last Modified by GUIDE v2.5 11-Feb-2012 19:23:35

% Begin initialization code - DO NOT EDIT
disp('---sift_experiment_gui---')
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sift_experiment_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @sift_experiment_gui_OutputFcn, ...
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
%==========================================================================



function set_img_index1(handles,i)
global img_index1
disp(['set_img_index1: ' int2str(i)])
img_index1 = i;
set(handles.img_index1_text,'String',int2str(img_index1));
%======================================================================




function set_img_index2(handles,i)
global img_index2
disp(['set_img_index2: ' int2str(i)])
img_index2 = i;
set(handles.img_index2_text,'String',int2str(img_index2));
%======================================================================





% --- Executes just before sift_experiment_gui is made visible.
function sift_experiment_gui_OpeningFcn(hObject, eventdata, handles, varargin)

disp('sift_experiment_gui_OpeningFcn')

% Choose default command line output for sift_experiment_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Initialize the indexes of the two images you will compare as a global 
%variable
set_img_index1(handles, -1);
set_img_index2(handles, -1);

%load_computed_data()

set_table_values(handles);
%==========================================================================




% --- Loads previously computed values so we dont have to waste time recomputing
%function load_computed_data()
%global PathName;
%global num_ground_truth;
%global ground_truth;
%global field_data;
%global computed_data;
%match_types = {'Default','No Broomstick','Bidirectional'};

%disp('load_computed_data')
%Load any computation we have done
%if exist([PathName 'computed_data.mat'],'file')
%  %load([PathName 'computed_data.mat'])
%else
%  computed_data = cell(num_ground_truth,1);
%  for i = 1:num_ground_truth
%    computed_data{i}.compared_to = cell(num_ground_truth,1); %Structure for storing data comparing this image i to another image j
%    computed_data{i}.max_num_matches = containers.Map; 
%    computed_data{i}.min_num_matches = containers.Map;
%    for j = 1:num_ground_truth
%      computed_data{i}.compared_to{j}.matching_info = containers.Map; %Map type of matching algorithm to matches           
%%%      for match_type = match_types
%        computed_data{i}.compared_to{j}.matching_info(match_type{1}) = struct('matches',[],'scores',[],'num_matches',-1);
%        %Contains Info about the matches you have so far encountered from a specific algorithm
%      end
%    end
%    for match_type = match_types    
%      computed_data{i}.max_num_matches(match_type{1}) = -1;
%      computed_data{i}.min_num_matches(match_type{1}) = 2147483647;
%    end
%%    computed_data{i}.num_matching_images = sum(ground_truth(:,field_data.name_index) == ground_truth(i,field_data.name_index))-1;
%    computed_data{i}.exact_same_images  = [];
%  end
%end
%==========================================================================



% --- callback for when an option is changed 
% sift_experiment_gui('update_options_callback',hObject,eventdata,guidata(hObject))
function set_table_values_callback(hObject, eveentdat, handles)
  disp('set_table_values_callback');
  options_changed = 1;
  set_table_values(handles);
%==========================================================================






% --- Function that sets the filtered values of the image tables
function set_table_values(handles)
global field_data;
global name_table;
global img_index1;
global img_index2;
global filter_type;
global table1_sorting;
global table2_sorting;
global current_keypoint_algorithm;
global current_matching_algorithm;

global sample_set
global sample_size;
disp('set_table_values')


%If an image is selected get it's name
current_name = '';
if img_index1 ~= -1
  current_name = query_property(img_index1,-1,'name');
end

%Set up the column names and allocate space for their data
table1_columnnames = {'Index','ImgId','Name','Num Matching Images','Max # Matches','Min # Matches'};
table2_columnnames = {'Index','ImgId','Name',['#' current_keypoint_algorithm ' Matches'], [current_matching_algorithm ' score']};
num_table1_columns = size(table1_columnnames,2);
num_table2_columns = size(table2_columnnames,2);
table1_column_data = cell(sample_size,num_table1_columns);
table2_column_data = cell(sample_size,num_table2_columns);

%Filtered indexes keep track of where we are 
%When not adding every piece of data
filtered_index1 = 1;
filtered_index2 = 1;

%Create data for each entry in each table
for i = 1:sample_size
  img_index = i;
  img_id = sample_set(i);
  name = query_property(i,-1,'name');
  
  num_matching_imgs = query_property(i,-1,'num_matching_imgs');
  num_matches = query_property(i,1:sample_size,'num_matches');
  min_num_matches = min(num_matches);
  max_num_matches = max(num_matches);

  num_matching_descriptors = -2;
  num_filtered_descriptors = -2;
  
  if get(handles.simlar_images_checkbox,'Value') == 0
    % This is buggy as hell. The exact_same_images doesnt seem to be working
    % Probably because it hits some weird threshold value in run_sift_experiment 
    % and registers wrong matches. Then it thinks images that aren't the same are exactly the same
    % weird
    %if isfield(computed_data{i},'exact_same_images')
    %  num_matching_imgs = max(0,num_matching_imgs - size(computed_data{i}.exact_same_images,2));
    %end  
  end

  %if eval(get(handles.min_matches_text,'String')) > num_matching_imgs
  %  continue;
  %end

  %Table1 Values
  table1_column_data{filtered_index1,1} = img_index;
  table1_column_data{filtered_index1,2} = img_id;
  table1_column_data{filtered_index1,3} = name;
  table1_column_data{filtered_index1,4} = num_matching_imgs;
  table1_column_data{filtered_index1,5} = max_num_matches;
  table1_column_data{filtered_index1,6} = min_num_matches;


  filtered_index1 = filtered_index1 + 1;
  
  %Check if there are any filters. If there are only add specific table 2 values
  if img_index1 ~= -1
    if img_index1 == i 
      continue
    end
    %Check if you want to turn of images that are too similar
    %TODO Reimplement this, it's not that important though
    %if get(handles.simlar_images_checkbox,'Value') == 0
    %  if isfield(computed_data{img_index1}.compared_to{i},'exact_same_image')
    %    if computed_data{img_index1}.compared_to{i}.exact_same_image
    %      continue
    %    end
    %  end
    %end
    %You want only different images
    if strcmp(filter_type,'diff') == 1 & strcmp(current_name,name) == 1
      continue
    end
    %You want only the same images
    if strcmp(filter_type,'same') == 1 & (strcmp(current_name,name) ~= 1 | img_index1 == i)
      continue
    end
    num_matching_descriptors = query_property(img_index1,i,'num_matches');
  else
    continue
  end

  
  %Table2 Values
  table2_column_data{filtered_index2,1} = img_index;
  table2_column_data{filtered_index2,2} = img_id;
  table2_column_data{filtered_index2,3} = name;
  table2_column_data{filtered_index2,4} = double(num_matching_descriptors);
  table2_column_data{filtered_index2,5} = query_property(img_index1,i,'similarity');
  
  filtered_index2 = filtered_index2 + 1;
end

if strcmp(table1_sorting,'Most Matches')
  table1_column_data = flipud(sortcell(table1_column_data,5));
elseif strcmp(table2_sorting,'Least Matches')
  table1_column_data = sortcell(table1_column_data,5);
end
if strcmp(table2_sorting,'Most Matches')
  table2_column_data = flipud(sortcell(table2_column_data,4));
elseif strcmp(table2_sorting,'Least Matches')
  table2_column_data = sortcell(table2_column_data,4);
end

%Give the data to the uitables
set(handles.image1_table, 'ColumnName',     table1_columnnames,...
                          'ColumnEditable', boolean(zeros(1,num_table1_columns)),...%Set to all false
                          'Data',           table1_column_data);

set(handles.image2_table, 'ColumnName',     table2_columnnames,...
                          'ColumnEditable', boolean(zeros(1,num_table2_columns)),...%Set to all false
                          'Data',           table2_column_data);
%==========================================================================



% --- callback for when an option is changed 
% sift_experiment_gui('update_options_callback',hObject,eventdata,guidata(hObject))
function update_options_callback(hObject, eveentdat, handles)
  disp('update_options_callback')

  global options_changed ;
  global img_index1;
  global img_index2;
  options_changed = 1;
  manage_experiment(handles,img_index1,img_index2);
%==========================================================================





% --- Outputs from this function are returned to the command line.
function varargout = sift_experiment_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
%==========================================================================






% --- Executes on button press in load_data_button.
function load_data_button_Callback(hObject, eventdata, handles)
%==========================================================================




% --- Runs an experiment 
function manage_experiment(handles,i,j)
%disp(['manage_experiment [' int2str(i) ', ' int2str(j) ']'])
global options_changed;
persistent prev_i;
persistent prev_j;

%set_status(handles,'Computing.. Please wait');

%Check if anything significant has changed
need_to_rerun = 0;
if isempty(prev_i)      |...
  prev_i ~= i |...
  prev_j ~= j |...
  options_changed == 1
  need_to_rerun = 1;
end

%If you need to rerun do it
if need_to_rerun & i ~= -1 & j ~= -1

  update_table = query_property(i,j,'num_matches');

  options = update_options(handles);
  
  run_matching_experiment(i,j);

  if options.displayon == 1
    if update_table < 0
      set_table_values(handles)
    end
    %Refocus this gui after you run an experiment
    figure(handles.figure1)
  end
end

prev_i = i;
prev_j = j;
options_changed = 0;
%==========================================================================





% --- Executes when selected cell(s) is changed in image1_table.
function image1_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to image1_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global img_index1;
global img_index2;
disp('image1_table_CellSelectionCallback')

disable_gui_components(handles);

table1_data = get(handles.image1_table,'data');

if ~isempty(eventdata.Indices)
  set_img_index1(handles, table1_data{eventdata.Indices(1)});
end

% repopulate the table
set_table_values(handles)
table2_data = get(handles.image2_table,'data');
%If there is data in column 2 automatically run an experiment on the first row
if isempty(table2_data)
  set_img_index2(handles, -1);
else
  set_img_index2(handles, table2_data{1,1});
end
manage_experiment(handles,img_index1,img_index2);
enable_gui_components(handles);
%==========================================================================




% --- Executes when selected cell(s) is changed in image2_table.
function image2_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to image2_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global img_index1;
global img_index2;
disp('image2_table_CellSelectionCallback')

disable_gui_components(handles);
%If the table becomes unselected don't do anything
if isempty(eventdata.Indices) ~= 1
  table2_data = get(handles.image2_table,'data');
  set_img_index2(handles, table2_data{eventdata.Indices(1)});
  manage_experiment(handles,img_index1,img_index2);
end
enable_gui_components(handles);
%==========================================================================




% --- Gets and sets current options
function [options] = update_options(handles,varargin)
global current_keypoint_algorithm;
global current_matching_algorithm;
global options

%God this is messy, I need to clean up the way this application
%handles options TODO
if isempty(current_keypoint_algorithm)
  current_keypoint_algorithm = options.keypoint_algorithm
end
if isempty(current_matching_algorithm)
  current_matching_algorithm = options.matching_algorithm
end

options.displayon       = get(handles.display_on_checkbox,'Value');
options.showkeypoints   = get(handles.show_keypoints_checkbox,'Value');
options.showdescriptors = get(handles.show_descriptors_checkbox,'Value');
options.showallkeypoints = get(handles.show_all_keyoints_checkbox,'Value');
options.showmatches      = get(handles.show_matches_checkbox,'Value');
options.show_raw_matches = get(handles.show_raw_matches_checkbox,'Value');
options.keypoint_algorithm = current_keypoint_algorithm;
options.matching_algorithm = current_matching_algorithm;
options.figure          = 2;
%==========================================================================






% --- Executes on button press in display_on_checkbox.
function display_on_checkbox_Callback(hObject, eventdata, handles)
%==========================================================================






% --- Executes on button press in show_keypoints_checkbox.
function show_keypoints_checkbox_Callback(hObject, eventdata, handles)
%==========================================================================






% --- Executes on button press in show_descriptors_checkbox.
function show_descriptors_checkbox_Callback(hObject, eventdata, handles)
%==========================================================================





% --- Executes on button press in show_all_keyoints_checkbox.
function show_all_keyoints_checkbox_Callback(hObject, eventdata, handles)
%==========================================================================




% --- Executes when selected object is changed in filter_options_panel.
function filter_options_panel_SelectionChangeFcn(hObject, eventdata, handles)
global filter_type;
disp('filter_options_panel_SelectionChangeFcn')
filter_value = get(eventdata.NewValue,'String');
if  strcmp(filter_value, 'Same Images') == 1
  filter_type = 'same';
elseif strcmp(filter_value, 'Different Images') == 1
  filter_type = 'diff';
else
  filter_type = filter_value;
end
set_table_values(handles);
%==========================================================================





% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over display_on_checkbox.
function display_on_checkbox_ButtonDownFcn(hObject, eventdata, handles)
%======================================================================





% --- Disables gui components so stuff doesn't get messed up durring calculations
function disable_gui_components(handles)
set_status(handles,'Please wait');
%==========================================================================


% --- Enables gui components after calculations are done
function enable_gui_components(handles)
set_status(handles,'Ready');
%==========================================================================

% --- Sets a status
function set_status(handles,message)
set(handles.status_text,'String',['status: ' message]);
%==========================================================================



% --- Executes on button press in matching_experiment_click_debugger_but.
function matching_experiment_click_debugger_but_Callback(hObject, eventdata, handles)
%Run the click debugger script. It will let you select keypoints
%and get info about them
matching_experiment_click_debugger
%==========================================================================





% --- Executes when selected object is changed in sort_options_panel.
function sort_options_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in sort_options_panel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
disp('table2_sort_options_panel_SelectionChangeFcn')
global table2_sorting
table2_sorting = get(eventdata.NewValue,'String');
set_table_values(handles);
%======================================================================


% --- Executes on button press in simlar_images_checkbox.
function min_matches_text_Callback(hObject, eventdata, handles)
disp('min_matches_text_Callback')
set_table_values(handles);
%======================================================================






% --- Executes during object creation, after setting all properties.
function min_matches_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%======================================================================





% --- Executes on button press in show_matches_checkbox.
function show_matches_checkbox_Callback(hObject, eventdata, handles)
%======================================================================






% --- Executes on button press in filter_broomstick_matches_checkbox.
function filter_broomstick_matches_checkbox_Callback(hObject, eventdata, handles)
%======================================================================






% --- Executes when selected object is changed in keypoint_alg_panel.
function keypoint_alg_panel_SelectionChangeFcn(hObject, eventdata, handles)
global current_keypoint_algorithm;
global options_changed 
global img_index1;
global img_index2;
options_changed = 1;

disp('matching_alg_panel_SelectionChangeFcn')
current_keypoint_algorithm = get(eventdata.NewValue,'String');
set_table_values(handles);
manage_experiment(handles,img_index1,img_index2);
%======================================================================


% --- Executes when selected object is changed in matching_alg_panel.
function matching_alg_panel_SelectionChangeFcn(hObject, eventdata, handles)
global current_matching_algorithm;
global options_changed 
global img_index1;
global img_index2;
options_changed = 1;

disp('matching_alg_panel_SelectionChangeFcn')
current_matching_algorithm = get(eventdata.NewValue,'String');
set_table_values(handles);
manage_experiment(handles,img_index1,img_index2);
%======================================================================




% --- Executes when selected object is changed in table1_sorting_options.
function table1_sorting_options_SelectionChangeFcn(hObject, eventdata, handles)
global options_changed 
global img_index1;
global img_index2;
global table1_sorting
options_changed = 1;

disp('table1_sorting_options_SelectionChangeFcn')
table1_sorting = get(eventdata.NewValue,'String');
set_table_values(handles);
%======================================================================

%END OF FILE


% --- Executes on button press in show_raw_matches_checkbox.
function show_raw_matches_checkbox_Callback(hObject, eventdata, handles)
update_options_callback(hObject, eventdata, handles)

% --- Lets user select what img1 index should be
function img_index1_text_Callback(hObject, eventdata, handles)

set_img_index1(handles,str2double(get(hObject,'String')));
update_options_callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function img_index1_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to img_index1_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Lets user select what img2 index should be
function img_index2_text_Callback(hObject, eventdata, handles)
set_img_index2(handles,str2double(get(hObject,'String')));
update_options_callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function img_index2_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to img_index2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in recompute_but.
function recompute_but_Callback(hObject, eventdata, handles)
  global img_index1;
  global img_index2;
  disp(['Recomputing' int2str(img_index1) ' to ' int2str(img_index2)])
  run_matching_experiment(img_index1,img_index2,'recompute');
  disp('Done Recomputing')


% --- Executes during object creation, after setting all properties.
function keypoint_alg_panel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to keypoint_alg_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
