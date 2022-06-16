function [] = set_data_directory(new_directory)
global config
global gui_properties

if strcmp(new_directory,'')
  return
end

%Check to see the new directory exists. 
%Create if the user wants it
if ~exist(new_directory,'dir')
  answer = questdlg(['Directory: "' new_directory '" Does Not Exist. Create It?']);
  if strcmp(answer,'Yes')
    if ~mkdir(new_directory)
      errordlg(['Cannot Create Directory: "' new_directory '"'])
      return
    end
  else
    return
  end
end

%Make sure it is in the correct format
if (new_directory(end) ~= '/' && new_directory(end) ~= '\')
  new_directory = [new_directory '/'];
end

%If the main window is up set the property in the main window
if ~exist([new_directory 'image_info'],'dir') | ~exist([new_directory 'matches'],'dir')
  answer = questdlg(['Image Info or Matches Directory Does Not Exist. Create It?'])
  if strcmp(answer,'Yes')
    if ~mkdir([new_directory 'image_info']) | ~mkdir([new_directory 'matches'])
      errordlg(['Cannot Create Info Directories in directory: "' new_directory '"'])
      return
    end
  else
    return
  end
end

%Update global information now that everything is set up
config.data_directory = new_directory;

if (~isempty(gui_properties) && isfield(gui_properties,'handles') && ishandle(gui_properties.handles.data_directory_text))
  set(gui_properties.handles.data_directory_text,'String',config.data_directory)
end
