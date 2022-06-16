function [] = build_database()
global config

%Make sure keypoints are computed for every 
%Image in the sample set
progress_handle = waitbar(0,'Building Database');
set(progress_handle,'Position', get(progress_handle,'Position') + [100,-100,0 0])
for i = 1:config.sample_size
  waitbar(i/config.sample_size,progress_handle,['Computing Keypoints: ' num2str(i) '/' num2str(config.sample_size)]);
  query_property(i,-1,'keypoints','disable_progress');
end

%Compute matches
[imatch jmatch] = meshgrid(1:config.sample_size,1:config.sample_size);
legal_matches = imatch < jmatch;
matches_to_compute = [imatch(legal_matches)'; jmatch(legal_matches)'];

iter = 1;
maxiter = size(matches_to_compute,2);
for ij = matches_to_compute
  waitbar(iter/maxiter,progress_handle,['Computing Matches: ' num2str(ij(1)) ' to ' num2str(ij(2))]);
  get_computed_match(ij(1),ij(2),'disable_progress');
  iter = iter + 1;
end

close(progress_handle)

