function [] = save_computed_statistics(i, statistics, varargin)
global StoredStatistics
global config
%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

save_in_memory = 0;
for var_index = 1:size(varargin,2)
  var = varargin{var_index}
  if strcmp(var,'save')
    save_in_memory = 1;
  end
  if strcmp(var,'release')
    save_in_memory = -1;
  end
end

if save_in_memory == -1
  StoredStatistics(i) = [];
end
%query_data will not be called when there
%is a value in computed data. Any index 
%not in StoredData will be recomputed
if StoredStatistics.isKey(i) | save_in_memory == 1
  StoredStatistics(i) = statistics;
else
filename = [config.data_directory 'image_info/image' int2str(i) '_' config.keypoint_detector  '_statistics.mat'];  
save(filename,'statistics')
end
