%Usage 
% [matches, scores] = get_computed_match(i,j)
%Because all matching algorithms are bidirectional this will only compute image 1 to image 2 and use it as info for both
function [matches, scores, raw_matches, raw_scores] = get_computed_match(i,j,varargin)
global config;


nocompute = 0;
was_something_computed = 0;
matches = [];
scores = [];


%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

recompute = 0;
nospatialconsistency = 0;
display_on = 0;
enable_progress = 1;
for var = varargin
  if strcmp(var,'recompute')
    recompute = 1;
  end
  if strcmp(var,'recomputematches')
    recompute = 1;
  end
  if strcmp(var,'nospatialconsistency')
    nospatialconsistency = 1;
  end
  if strcmp(var,'display_on')
    display_on = 1;
  end
  if strcmp(var,'display_off')
    display_on = 0;
  end
  if strcmp(var,'disable_progress')
    enable_progress = 0;
  end
end

%Cant match to yourself
if j == i
  return
end

%Set to non 0 if j is less than i
swap_order = 0;
%Matches are bidirectional so only compute each one once
if j < i
 swap_order = i;
 i = j;
 j = swap_order;
end

i_index = config.sample_set(i);
j_index = config.sample_set(j);

filename = [config.data_directory 'matches/image' int2str(i_index) 'to' int2str(j_index) '_' config.keypoint_detector '_' config.matching_algorithm '_matches.mat'];

%Automatically recompute if the file doesn't exist
recompute = recompute | ~exist(filename); 

if recompute | display_on  
  if enable_progress
    progress_handle = waitbar(0,'Computing Match: Initializing');
  end
  f1 = query_property(i,-1,'keypoints',varargin);
  f2 = query_property(j,-1,'keypoints',varargin);
  d1 = query_property(i,-1,'descriptors');
  d2 = query_property(j,-1,'descriptors');
  
  %Get matches using the ratio test and whatever bells and whistles 
  %the current keypoitns/descriptors call for

  %Check recompute again. If we are just displaying, we need to 
  %Redo RANSAC, but don't redo matching
  if strcmp(config.keypoint_detector,'harris') == 1
    if strcmp(config.matching_algorithm,'noratio') == 1
      if enable_progress
        waitbar(.2,progress_handle,'Computing Match: Computing NoRatio Matches');
      end
      [raw_matches, raw_scores] = get_match_noratio(i, j, f1, f2,single(d1), single(d2), varargin);
    elseif strcmp(config.matching_algorithm,'bidirectional')
      if enable_progress
        waitbar(.2,progress_handle,'Computing Match: Computing Bidirectional Matches');
      end
      [raw_matches, raw_scores] = get_match_harris(i, j, f1, f2,single(d1), single(d2), varargin);
    end
  elseif strcmp(config.keypoint_detector,'sift') == 1
    if enable_progress
      waitbar(.2,progress_handle,'Computing Match: Computing Bidirectional Matches');    
    end
    [raw_matches, raw_scores] = get_match_bidirectional(f1, f2, d1, d2, varargin);
  end

  img1 = get_zebra(i);
  img2 = get_zebra(j);
  
  ransac_dist_thresh = min(size(img2,1),size(img1,2))*.2;

  %Verify the spatial consistency of the raw matches
  if nospatialconsistency
    matches = raw_matches;
    consistent_indexes = 1:size(matches,2);
  else
    if enable_progress
      waitbar(.5,progress_handle,'Computing Match: Computing Spatial Consistency');        
    end
    [matches, consistent_indexes, H1, H2] = compute_spatially_consistent_matches(i,j,f1,f2,raw_matches,ransac_dist_thresh,varargin);
  end
  scores = raw_scores(consistent_indexes);

  %Get computed match manages it's own data and is not touched by properties
  save(filename,'matches','scores','raw_matches','raw_scores');

  num_matches = size(matches,2);
  set_property(num_matches,i,j,'num_matches');
  set_property(num_matches,j,i,'num_matches');
  
  if enable_progress
    waitbar(.9,progress_handle,'Computing Match: Saving Information');        
  end

  %TODO right now num_matches = num_inliers
  num_matches = size(matches,2);
  set_property(num_matches,i,j,'num_matches');
  set_property(num_matches,j,i,'num_matches');

  set_property(num_matches,i,j,'num_inliers');
  set_property(num_matches,j,i,'num_inliers');

  if enable_progress
    waitbar(1,progress_handle,'Computing Match: Finished');   
    close(progress_handle)
  end

else
  load(filename);
end

%If we swapped i and j, swap back
if swap_order > 0
  matches = flipud(matches);
  scores = flipud(scores);
  raw_matches = flipud(raw_matches);
  raw_scores = flipud(raw_scores);
end
