function [] = save_computed(computed,varargin)
global StoredData
global config

imgindex = computed.imgindex;

if imgindex <= 0
  msgbox('Inavlid Image ID in save_computed');
  computed
  disp('Inavlid Image ID in save_computed');
end

%Hack so you can pass down varargin from parent functions
if (size(varargin) == [1 1] & isa(varargin{1},'cell'))
  varargin = varargin{1};
end

if isempty(StoredData)
  StoredData = containers.Map('KeyType','double','ValueType','any');
end

save_in_memory = 1;
write_to_disk = 0;
for var_index = 1:size(varargin,2)
  var = varargin{var_index};
  if strcmp(var,'write')
    write_to_disk = 1;
  end
  if strcmp(var,'save')
    save_in_memory = 1;
  end
  if strcmp(var,'release')
    save_in_memory = -1;
  end
end

if save_in_memory == -1
  StoredData(imgindex) = [];
end
%query_data will not be called when there
%is a value in computed data. Any index 
%not in StoredData will be recomputed
if (save_in_memory == 1)
  StoredData(imgindex) = computed;
  if write_to_disk
    filename = sprintf('%s/computed_info/computed-%07d.mat',config.data_directory, imgindex);
    save(filename,'computed');
  end
else
  filename = sprintf('%s/computed_info/computed-%07d.mat',config.data_directory, imgindex);
  save(filename,'computed');
end
