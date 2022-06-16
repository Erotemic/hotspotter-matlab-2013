function [gt_ret] = load_ground_truth()
%For now just store groundtruth in memory at all times
%Don't think this will need to change
global ground_truth
global config

filename = [config.data_directory 'ground_truth.mat'];

if ~exist(filename,'file') 
  ground_truth = struct;
  ground_truth.num_gtids = 0;
  ground_truth.gtid_to_names  = containers.Map('KeyType','double','ValueType','any');
  ground_truth.names_to_gtid  = containers.Map('KeyType','char','ValueType','any');  
  ground_truth.gtid_to_imgids = containers.Map('KeyType','double','ValueType','any');
  save_ground_truth(ground_truth);  
else
  if isempty(ground_truth)
    load(filename)
  end
end

gt_ret = ground_truth;
