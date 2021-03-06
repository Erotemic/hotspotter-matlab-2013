%GUI initialization
function varargout = database_window(varargin)
  gui_Singleton = 1;
  gui_State = struct('gui_Name',       mfilename, ...
                     'gui_Singleton',  gui_Singleton, ...
                     'gui_OpeningFcn', @database_window_OpeningFcn, ...
                     'gui_OutputFcn',  @database_window_OutputFcn, ...
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


% --- Executes just before database_window is made visible.
function database_window_OpeningFcn(hObject, eventdata, handles, varargin) 
  global database_window_handles;
  database_window_handles = handles;
  database_window_handles.set_database_name_table_handle = @set_database_name_table;
  handles.output = hObject;
  guidata(hObject, handles);
  axes(handles.database_axes);
  imshow(repmat([.5],[20,35]));
  set(gca,'XTickLabel',[])
  set(gca,'YTickLabel',[])
  set(gca,'XTick',[])
  set(gca,'YTick',[])
  load_sighting_data_csv();
  set_database_name_table()


% --- Outputs from this function are returned to the command line.
function varargout = database_window_OutputFcn(hObject, eventdata, handles) 
  varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function database_name_table_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end



% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in add_images_button.
function add_images_button_Callback(hObject, eventdata, handles)
find_matches = find_matches_window();
disp('add_images_button');



function set_database_name_table()
  global database
  global database_window_handles

  table_column_names = {'Animal Name', 'Image Ids'};
  num_columns = size(table_column_names,2);
  
  animal_names = database.name_to_imgindex.keys()';
  animal_imgids =  cellfun(@(x) num2str(database.name_to_imgindex(x)), animal_names,'UniformOutput',false)
 
  table_column_data = [animal_names animal_imgids];

  set(database_window_handles.database_name_table,...
    'ColumnName',     table_column_names,...
    'ColumnEditable', logical(zeros(1,num_columns)),...%Set to all false
    'Data',           table_column_data);

  set(database_window_handles.sample_set_display_text,'String', ['Loaded: ' num2str(database.num_animals) ' Animals, ' num2str(database.num_images) ' Images'] );
  
% --- Executes when selected cell(s) is changed in database_name_table.
function database_name_table_CellSelectionCallback(hObject, eventdata, handles)
global database
global database_window_handles

disp('name_table_cell_selection');
animal_name_data = get(hObject,'Data');

if (~isempty (eventdata) && ~isempty(eventdata.Indices))
  selected_name = animal_name_data{eventdata.Indices};
  selected_imgids = database.name_to_imgindex(selected_name);
  selected_info = load_computed( selected_imgids(1) );
  axes(database_window_handles.database_axes);
  imshow(get_database_image(selected_imgids(1)));
  set(gca,'XTickLabel',[]);
  set(gca,'YTickLabel',[]);
  set(gca,'XTick',[]);
  set(gca,'YTick',[]);

  %Set how the slider moves so you can show the different imgids
  %belonging to this zebra name
end


function sample_set_text_Callback(hObject, eventdata, handles)
global database
database.sample_set_str = get(handles.sample_set_text,'String');

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


% --- Executes during object creation, after setting all properties.
function img_index_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to img_index_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in save_sighting_data_but.
function save_sighting_data_but_Callback(hObject, eventdata, handles)
disp('saving data');
save_sighting_data_csv()
