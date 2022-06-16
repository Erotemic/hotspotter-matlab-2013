function [gtid] = get_gtid_from_name(name)
ground_truth = load_ground_truth();

if ~ground_truth.names_to_gtid.isKey(name)
  gtid = -1;
else
  gtid = ground_truth.names_to_gtid(name)
end
