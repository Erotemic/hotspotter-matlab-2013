%This matching algorithm is a ratio test followed by an orientation consistency step
%The ratio test disregards second closest points that are in the same exact place and allows for 
%multiple keypoints to be found at the same place in different scales / orientations 

function [matches, scores]  = get_match_noratio(i, j, f1, f2, d1, d2 ,varargin)
global ground_truth
global field_data
global name_table
global PathName

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

ratio_thresh = 1.5;

forest1 = vl_kdtreebuild(d1);
forest2 = vl_kdtreebuild(d2);

%tic;
%Find descriptor distances from j to i
[indexes_dir1, dists_dir1] = vl_kdtreequery(forest1,d1,d2,'NUMNEIGHBORS',1);
%Find descriptor distances from i to j
[indexes_dir2, dists_dir2] = vl_kdtreequery(forest2,d2,d1,'NUMNEIGHBORS',1);
%toc;

%Get the matches in direction 1 that pass the ratio test of distinctivness
matches_dir1_all = [1:size(indexes_dir1,2); indexes_dir1];

%Get the matches in direction 1 that pass the ratio test of distinctivness
matches_dir2_all = [1:size(indexes_dir2,2); indexes_dir2];

%Get only the bidirectional matches
%This way both actual keypoints have to join test this against just keypoint locations
[matches, IA, ~] = intersect(matches_dir1_all', flipud(matches_dir2_all)','rows');
matches = fliplr(matches)';
%Give back score later
scores = dists_dir1(IA);

