function varargout = find_matches_window(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @find_matches_window_OpeningFcn, ...
                   'gui_OutputFcn',  @find_matches_window_OutputFcn, ...
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




% --- Outputs from this function are returned to the command line.
function varargout = find_matches_window_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;



function sighting_id_text_Callback(hObject, eventdata, handles)

function sighting_id_text_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end


function group_size_text_Callback(hObject, eventdata, handles)

function group_size_text_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end



function notes_text_Callback(hObject, eventdata, handles)

function notes_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minute_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function minute_text_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end



function day_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function day_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function year_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function year_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hour_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function hour_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function month_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function month_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function reproductive_status_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function reproductive_status_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function age_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function age_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function location_text_Callback(hObject, eventdata, handles)

function location_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function animal_name_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function animal_name_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function data_dir_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lat_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function lat_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lon_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function lon_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Editable code
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before find_matches_window is made visible.
function find_matches_window_OpeningFcn(hObject, eventdata, handles, varargin)
%Create a global selected animal so functions have access 
%to the selection properties
global query_animal_info;
global find_matches_handles;

query_animal_info.image_path = '';
query_animal_info.roi = [0 0 2 1];
query_animal_info.image_size = [1 2];
query_animal_info.image = [.5 .5];

query_animal_info.keypoints = [];
query_animal_info.descriptors = [];
query_animal_info.num_matches = [];

find_matches_handles = handles;

handles.output = hObject;
guidata(hObject, handles);

[year month day hour minute ~] = datevec(now);
set(handles.year_text,'String',year)
set(handles.month_text,'String',month)
set(handles.day_text,'String',day)
set(handles.hour_text,'String',hour)
set(handles.minute_text,'String',minute)


% --- Executes on button press in save_animal_but.
function save_animal_but_Callback(hObject, eventdata, handles)
  global query_animal_info;
  global database_window_handles;
  
  month = str2num(get(handles.month_text,'String'));
  day = str2num(get(handles.day_text,'String'));
  year = str2num(get(handles.year_text,'String'));
  hour = str2num(get(handles.hour_text,'String'));
  minute = str2num(get(handles.minute_text,'String'));


  animal_info = struct;
  animal_info.imgindex = -1;
  animal_info.original_filepath = query_animal_info.image_path;
  animal_info.roi = query_animal_info.roi;
  animal_info.animal_name = get(handles.animal_name_text,'String');
  animal_info.sighting_id = get(handles.sighting_id_text,'String');
  animal_info.flank = get(get(handles.flank_panel,'SelectedObject'),'String');
  animal_info.notes = get(handles.notes_text,'String');  
  animal_info.photo_quality = get(get(handles.photo_quality_panel,'SelectedObject'),'String');
  animal_info.sighting_date = [year month day];  
  animal_info.sighting_time = [hour minute 0];
  animal_info.exposure_time = '';
  animal_info.focal_length = '';
  animal_info.aperture_Fnumber = '';
  animal_info.camera_info = '';
  animal_info.sex = get(get(handles.sex_panel,'SelectedObject'),'String');
  animal_info.age = str2num(get(handles.age_text,'String'));
  animal_info.sighting_location = '';
  animal_info.group_size = get(handles.group_size_text,'String');
  animal_info.gps_lat = str2num(get(handles.lat_text,'String'));
  animal_info.gps_lon = str2num(get(handles.lon_text,'String'));
  animal_info.reproductive_status = get(handles.reproductive_status_text,'String');

  animal_info.keypoints = query_animal_info.keypoints;
  animal_info.descriptors = query_animal_info.descriptors;
  animal_info.num_matches = query_animal_info.num_matches;

  query_animal_info.num_matches = query_animal_info.num_matches;

  
  if (isempty(month) || isempty(day) || isempty(year) || isempty(hour) || isempty(minute)) 
     msgbox('Datetime is invalid') 
     return
  elseif (~(month > 0 && month <= 12 && hour > 0 && hour <= 24 && day > 0 && day <= 32 && minute >= 0 && minute < 60 ))
     msgbox('Datetime is out of range')
     return
  end

  lat = animal_info.gps_lat;
  lon = animal_info.gps_lon;
  if (isempty(lat) || isempty(lon)) 
      animal_info.gps_lat = '';
      animal_info.gps_lon = '';
  elseif (~(lat >=-90 && lat <=90 && lon >=-180 && lon <=180))
      msgbox('GSP is out of range')
      return
  end

  add_image_to_database(animal_info);

  %Reset computations after saving an animal
  query_animal_info.keypoints = [];
  query_animal_info.descriptors = [];
  query_animal_info.num_matches = [];
  database_window_handles.set_database_name_table_handle();


function data_dir_text_Callback(hObject, eventdata, handles)
  disp('data dir text select');
  select_data_directory(get(hObject,'String'),handles);



function select_data_dir_but_Callback(hObject, eventdata, handles)
  disp('data dir button pressed');
  select_data_directory(uigetdir,handles);



% --- Executes on button press in find_probable_match_but.
function find_probable_match_but_Callback(hObject, eventdata, handles)
  global query_animal_info
  query_animal_info = query_probable_matches(query_animal_info);
  update_query_image_axes();
  [nmatches_sorted, db_index_sorted] = sort(query_animal_info.num_matches,'descend');

  table_column_names = {'Image ID', 'Num Matches'};
  num_columns = size(table_column_names,2);
  table_column_data = [num2cell(db_index_sorted') num2cell(nmatches_sorted')]

  set(handles.probable_matches_table,...
    'ColumnName',     table_column_names,...
    'ColumnEditable', logical(zeros(1,1)),...%Set to all false
    'Data',           table_column_data);


function update_query_image_axes()
  global find_matches_handles;
  global query_animal_info;
  axes(find_matches_handles.query_axes);
  imshow(query_animal_info.image);
  set(gca,'XTickLabel',[]);
  set(gca,'YTickLabel',[]);
  set(gca,'XTick',[]);
  set(gca,'YTick',[]);
  
  if query_animal_info.roi(3) < 0 | query_animal_info.roi(4) < 0
      query_animal_info.roi = [1 1 size(query_animal_info.image,2) size(query_animal_info.image,1)];
  end
  rectangle('Position',query_animal_info.roi,'EdgeColor','r','LineWidth',3);
  
  %Show keypoint locations
  if ~isempty(query_animal_info.keypoints)
    %hold on      
    %plot(query_animal_info.keypoints(1,:)+query_animal_info.roi(1), query_animal_info.keypoints(2,:)+query_animal_info.roi(2), 'rx');
    %hold off
  end
  
function update_probable_match_image_axes()
  global find_matches_handles;
  global db_animal_info;
  axes(find_matches_handles.probable_match_axes);
  imshow(get_database_image(db_animal_info.imgindex));
  set(gca,'XTickLabel',[]);
  set(gca,'YTickLabel',[]);
  set(gca,'XTick',[]);
  set(gca,'YTick',[]);
  
  rectangle('Position',db_animal_info.roi,'EdgeColor','r','LineWidth',3);
  
  db_animal_info
  %Show keypoint locations
  if ~isempty(db_animal_info.keypoints)
    %hold on      
    %plot(db_animal_info.keypoints(1,:)+db_animal_info.roi(1), db_animal_info.keypoints(2,:)+db_animal_info.roi(2), 'rx');
    %hold off
  end
  

% --- Executes when selected cell(s) is changed in query_image_table.
function query_image_table_CellSelectionCallback(hObject, eventdata, handles)
  global query_animal_info

  %Check to make sure indices and data is valid
  available_images = get(handles.query_image_table,'Data');
  if (isempty(eventdata) || isempty(eventdata.Indices) || isempty(available_images))
      return
  end
  %The selected filename is stored in the table data 
  selected_image = available_images{eventdata.Indices(1)};
  if ~exist(selected_image)
    return
  end

  if ~isempty(query_animal_info.keypoints)
    if strcmp(questdlg('Animal has not been saved. Computed information will be lost. Continue?','Maybe','No','Yes','No'),'No')
      return
    end
    query_animal_info.keypoints = [];
    query_animal_info.descriptors = [];
    query_animal_info.num_matches = [];
  end

  query_animal_info.image_path = selected_image;
  query_animal_info.image = imread(selected_image);
  query_animal_info.roi = [1 1 size(query_animal_info.image,2) size(query_animal_info.image,1)];
  query_animal_info.image_size = size(query_animal_info.image);
  query_animal_info.imgindex = -1;

  update_query_image_axes();


  

% --- Executes on button press in pick_roi_but.
function pick_roi_but_Callback(hObject, eventdata, handles)
global query_animal_info

if ~isempty(query_animal_info.keypoints)
  if strcmp(questdlg('Animal has not been saved. Computed information will be lost. Continue?','Maybe','No','Yes','No'),'No')
    return
  end
  query_animal_info.keypoints = [];
  query_animal_info.descriptors = [];
  query_animal_info.num_matches = [];
end

axes(handles.query_axes);
[x,y] = ginput(2);

tl = [max(min(x),1) max(min(y),1)];
br = [min(max(x),query_animal_info.image_size(2)) min(max(y),query_animal_info.image_size(1))];

query_animal_info.roi = [tl(1), tl(2), br(1) - tl(1), br(2) - tl(2)];
update_query_image_axes();

% --- Executes on key press with focus on animal_name_text and none of its controls.
function animal_name_text_KeyPressFcn(hObject, eventdata, handles)
global database
%Hack because matlab doesn't always update text values
if ~isequal(eventdata.Key,'return')
    import java.awt.Robot;
    import java.awt.event.KeyEvent;
    robot=Robot;
    robot.keyPress(KeyEvent.VK_ENTER);
    pause(0.01)
    robot.keyRelease(KeyEvent.VK_ENTER);
end

animal_name_str = get(handles.animal_name_text,'String');

if isempty(animal_name_str)
    set(handles.save_animal_but,'Enable','off');  
    set(handles.save_animal_but,'String','Invalid Name');
    set(handles.save_animal_but,'ForegroundColor',[.5 .5 .5]);
elseif ~database.name_to_imgindex.isKey(animal_name_str)
    set(handles.save_animal_but,'Enable','on');  
    set(handles.save_animal_but,'String','Invalid Name');
    set(handles.save_animal_but,'String','Save As New Animal');
    set(handles.save_animal_but,'ForegroundColor',[0 0 1]);
else 
    set(handles.save_animal_but,'Enable','on');  
    set(handles.save_animal_but,'String','Accept Match');
    set(handles.save_animal_but,'ForegroundColor',[1 0 0]);
end


function select_data_directory(new_directory, handles)
  %Check to see if the new directory exists
  query_images = {};
  if ~strcmp(class(new_directory),'char') | ~exist(new_directory,'dir')
      msgbox(['Data Directory "' new_directory '" does not exist']);
      return;
  else
      query_images = list_files(new_directory,'image_only');
      set(handles.data_dir_text,'String',new_directory);
  end
  
  table_column_names = {'Image Name'};
  num_columns = size(table_column_names,2);
  table_column_data = query_images;

  set(handles.query_image_table,...
    'ColumnName',     table_column_names,...
    'ColumnEditable', logical(zeros(1,1)),...%Set to all false
    'Data',           table_column_data);


% --- Executes when selected cell(s) is changed in probable_matches_table.
function probable_matches_table_CellSelectionCallback(hObject, eventdata, handles)
  global db_animal_info
  hObject
  
  %Check to make sure indices and data is valid
  probable_matches = get(handles.probable_matches_table,'Data');
  if (isempty(eventdata) || isempty(eventdata.Indices) || isempty(probable_matches))
      return
  end
  %The selected filename is stored in the table data 
  db_imgindex = probable_matches{eventdata.Indices(1),1}
  db_animal_info = load_computed(db_imgindex);
  set(handles.animal_name_text,'String',db_animal_info.animal_name);
  eventdata.Key = 'return';
  animal_name_text_KeyPressFcn(hObject, eventdata, handles)
  update_probable_match_image_axes();
