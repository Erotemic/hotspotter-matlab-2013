global config;

for i = 1:config.sample_size
  query_property(i,-1,'keypoints','recompute');
end
