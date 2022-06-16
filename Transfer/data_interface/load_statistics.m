%Statistics are data between this image and all other images. 
function [statistics] = load_statistics(i_index,varargin)
global StoredStatistics
global config

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

%Stored data will keep track of which 
%values the user has requested to store in 
%memory as to not thrash the disk
if isempty(StoredStatistics)
  StoredStatistics = containers.Map('KeyType','double','ValueType','any');
end


recompute = 0;

for var_index = 1:size(varargin,2)
  var = varargin{var_index};
  if strcmp(var,'recompute')
    recompute = 1;
  end
end

filename = [config.data_directory 'image_info/image' int2str(i_index) '_' config.keypoint_detector '_statistics.mat'];

%This is duplicate code also in query_proprety fix later
if StoredStatistics.isKey(i_index) & ~recompute
  statistics = StoredData(i_index);
elseif ~exist(filename,'file') | recompute

  %Each match has statistics
  statistics = struct('num_matches',-ones(config.num_images,1),...
                      'similarity' ,-ones(config.num_images,1),...
                      'num_inliers' ,-ones(config.num_images,1),...
                      'probability_match',-ones(config.num_images,1));

  save_statistics(i_index,statistics);  
else
  load(filename);
  %Make sure new images havne't been added since 
  %the statistics were created
  size_difference = config.num_images - size(statistics.num_matches,1);
  if (size(statistics.num_matches,1) < config.num_images)
    statistics.num_matches = [statistics.num_matches ; -ones(size_difference,1)];
    statistics.similarity  = [statistics.similarity  ; -ones(size_difference,1)];
    statistics.num_inliers = [statistics.num_inliers ; -ones(size_difference,1)];
    statistics.probability_match = [statistics.probability_match ; -ones(size_difference,1)];
    save_statistics(i_index,statistics);    
  end
end
