%Usage 
% [matches, scores] = get_computed_match(i,j)
%Because all matching algorithms are bidirectional this will only compute image 1 to image 2 and use it as info for both
function [matches, scores, raw_matches, raw_scores] = get_computed_match(animal1,animal2,varargin)

nocompute = 0;
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

if enable_progress
  progress_handle = waitbar(0,'Computing Match: Initializing');
end
f1 = animal1.keypoints;
d1 = animal1.descriptors;
f2 = animal2.keypoints;
d2 = animal2.descriptors;

%Get matches using the ratio test and whatever bells and whistles 
%the current keypoitns/descriptors call for

%Check recompute again. If we are just displaying, we need to 
%Redo RANSAC, but don't redo matching
if enable_progress
  waitbar(.2,progress_handle,'Computing Match: Computing Bidirectional Matches');
end
[raw_matches, raw_scores] = get_match_harris(f1, f2,single(d1), single(d2), varargin);


ransac_dist_thresh = min([animal1.roi(3:4) animal2.roi(3:4)])*.2;

%Verify the spatial consistency of the raw matches
if nospatialconsistency
  matches = raw_matches;
  consistent_indexes = 1:size(matches,2);
else
  if enable_progress
    waitbar(.5,progress_handle,'Computing Match: Computing Spatial Consistency');        
  end
  [matches, consistent_indexes, H1, H2] = compute_spatially_consistent_matches(f1,f2,raw_matches,ransac_dist_thresh,varargin);
end
scores = raw_scores(consistent_indexes);

if enable_progress
  waitbar(1,progress_handle,'Computing Match: Finished');   
  close(progress_handle)
end
