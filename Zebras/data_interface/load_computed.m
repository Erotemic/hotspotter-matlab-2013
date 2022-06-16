function [computed, isnew] = load_computed(imgindex,varargin)
global StoredData
global config
global prev_computed;

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

%Stored data will keep track of which 
%values the user has requested to store in 
%memory as to not thrash the disk
if isempty(StoredData)
  StoredData = containers.Map('KeyType','double','ValueType','any');
end


if nargout > 1
  isnew = 0;
end

save_in_memory = 1;

for var_index = 1:size(varargin,2)
  var = varargin{var_index};
  if strcmp(var,'recompute')
    disp('this cant recompute');
  end
  if strcmp(var,'save')
    save_in_memory = 1;
  end
end

filename = sprintf('%s/computed_info/computed-%07d.mat',config.data_directory, imgindex);

%This is duplicate code also in query_proprety fix later
if (StoredData.isKey(imgindex))
  computed = StoredData(imgindex);
  return;
%Cache the query
elseif (~isempty(prev_computed) && prev_computed.imgindex == imgindex)
  computed = prev_computed;
  return;
elseif (~exist(filename,'file'))
  %A datafile for this image doesn't exist. Create one. 
  computed = struct;
  computed.imgindex = -1;
  computed.original_filepath = '';
  computed.roi = [];
  computed.animal_name = '';
  computed.sighting_id = '';
  computed.sighting_date = [];    
  computed.sighting_time = [];    
  computed.exposure_time = '';
  computed.focal_length = '';
  computed.aperture_Fnumber = '';
  computed.camera_info = '';
  computed.flank = '';
  computed.notes = '';
  computed.photo_quality = '';
  computed.aperture_Fnumber = '';
  computed.camera_info = '';
  computed.sex = '';
  computed.age = '';
  computed.sighting_location = '';
  computed.group_size = '';
  computed.gps_lat = '';
  computed.gps_lon = '';
  computed.reproductive_status = '';
  
  computed.keypoints = [];
  computed.descriptors = [];

  %Stores the image to image matching score
  %indexes into this array are imgindex's 
  computed.num_matches = [];
  
  if nargout > 1
    isnew = 1;
  end
else
  load(filename);
  StoredData(imgindex) = computed;  
end
