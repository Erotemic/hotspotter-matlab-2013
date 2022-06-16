function [computed] = load_computed(i_index,varargin)
global StoredData
global config
global computed_fields;
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

recompute = 0;

for var_index = 1:size(varargin,2)
  var = varargin{var_index};
  if strcmp(var,'recompute')
    recompute = 1;
  end
end

filename = [config.data_directory 'image_info/image' int2str(i_index) '_' config.keypoint_detector '_info.mat'];

%This is duplicate code also in query_proprety fix later
if StoredData.isKey(i_index) & ~recompute
  computed = StoredData(i_index);
  return;
%Cache the query
elseif ~isempty(prev_computed) & prev_computed.img_id == i_index
  computed = prev_computed;
  return;
elseif ~exist(filename,'file') | recompute
  %A datafile for this image doesn't exist. Create one. 
  computed = struct;
  for field_value_pair = computed_fields
    computed = setfield(computed,field_value_pair{1},field_value_pair{2});
  end
  computed.img_id = i_index;
  computed.original_image_location = config.image_filenames{i_index};
  computed.name = ['unknown_' num2str(i_index)];
  save_computed(i_index,computed);  
else

  load(filename);
  
  if 1
    %Uncomment this code when adding new properties
    %Also TODO figure out a better way to store properties
    new_values_exist = 0;
    for field_value_pair = computed_fields
      if ~isfield(computed,field_value_pair{1})
        
        if strcmp(field_value_pair{1},'img_id')
          computed.img_id = i_index;
        elseif strcmp(field_value_pair{1},'original_image_location')
          computed.original_image_location = config.image_filenames{i_index};
        elseif strcmp(field_value_pair{1},'name')
          computed.name = ['unknown_' num2str(i_index)];
        else
          computed = setfield(computed,field_value_pair{1},field_value_pair{2});
        end
        new_values_exist = 1;
      end
    end
    if new_values_exist
      save_computed(i_index,computed);  
    end
  end

end
