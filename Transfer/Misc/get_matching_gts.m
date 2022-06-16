%Returns all names of ground truths at this index
function [match_indexes] = get_matching_gts(gt_index,num2get)
global ground_truth
global field_data

match_indexes = ground_truth((ground_truth(: ,field_data.name_index) == ground_truth(gt_index ,field_data.name_index)), field_data.gt_index);

match_indexes = match_indexes(match_indexes ~= gt_index);

if exist('num2get')
  match_indexes = match_indexes(num2get);
end
