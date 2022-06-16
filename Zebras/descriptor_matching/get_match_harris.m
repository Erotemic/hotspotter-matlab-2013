%This matching algorithm is a ratio test followed by an orientation consistency step
%The ratio test disregards second closest points that are in the same exact place and allows for 
%multiple keypoints to be found at the same place in different scales / orientations 

function [matches, scores]  = get_match_harris(f1, f2, d1, d2 ,varargin)

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

ratio_thresh = 1.8;

%Old method of getting max detection numbers was the largest number of 
%scales detected at one keypoint. 
%tic;
%[B1,I1,keypoint_id1] = unique(f1(1:2,:)','rows');
%neighbors_to_search1 = max(hist(keypoint_id1,max(keypoint_id1)-min(keypoint_id1)+1))+1;
%[B2,I2,keypoint_id2] = unique(f2(1:2,:)','rows');
%neighbors_to_search2 = max(hist(keypoint_id2,max(keypoint_id2)-min(keypoint_id2)+1))+1;
%toc;

forest1 = vl_kdtreebuild(d1);
forest2 = vl_kdtreebuild(d2);

%It hardly takes much more time to do 42 knn than it does to do 2  
%neighbors_to_search1 = 2;
%neighbors_to_search2 = 2;

%For now grab the distances to all other keypoints, because we dont know
%how many nearest neighbors we will need before we have a valid canidate
%for the ratio test. Let's be safe and fix this for speed later. 
%neighbors_to_search1 = size(d1,2);
%neighbors_to_search2 = size(d2,2);


%The maximum number of keypoints to get to ensure that there will exist a 
%keypoint outside of a threshold radius from the best match keypoint for 
%the ratio test. We don't want bad ratios because there were keypoints 
%detected to close together. 
neighbors_to_search1 = min(20, size(f1,2));%query_property(i,-1,'largest_keypoint_cluster')+1;
neighbors_to_search2 = min(20, size(f2,2));%query_property(j,-1,'largest_keypoint_cluster')+1;

%tic;
%Find descriptor distances from j to i
[indexes_dir1, dists_dir1] = vl_kdtreequery(forest1,d1,d2,'NUMNEIGHBORS',neighbors_to_search1,'MAXCOMPARISONS',neighbors_to_search1);
%Find descriptor distances from i to j
[indexes_dir2, dists_dir2] = vl_kdtreequery(forest2,d2,d1,'NUMNEIGHBORS',neighbors_to_search2,'MAXCOMPARISONS',neighbors_to_search2);

%toc;


%The best match is always the nearest neighbor
%i to j
%tic;
first_match_index1 = indexes_dir1(1,:);
first_match_dist1  = dists_dir1(1,:);
%The second match is the closest descriptor that is also at least 10 pixels away from the first
valid_second_pos1 = get_match_harris_helper_get_valid_second_positions(f1,indexes_dir1);
second_match_index1 = indexes_dir1(valid_second_pos1)';
second_match_dist1  = dists_dir1(valid_second_pos1)';

%The best match is always the nearest neighbor
%j to i
first_match_index2 = indexes_dir2(1,:);
first_match_dist2  = dists_dir2(1,:);
%The second match is the closest descriptor that is also at least 10 pixels away from the first
valid_second_pos2 = get_match_harris_helper_get_valid_second_positions(f2,indexes_dir2);
second_match_index2 = indexes_dir2(valid_second_pos2)';
second_match_dist2  = dists_dir2(valid_second_pos2)';
%toc;

%OLD CODE
%The best match is always the nearest neighbor
%first_match_index1 = indexes_dir1(1,:);
%first_match_dist1  = dists_dir1(1,:);
%Now find the second nearest neighbor that is not living at the same keypoint
%second_match_index1 = indexes_dir1(2,:);
%second_match_dist1 = dists_dir1(2,:);
%bad_second_match = keypoint_id1(first_match_index1) == keypoint_id1(second_match_index1);
%match_level = 3;
%while sum(bad_second_match) > 0
%  second_match_index1(bad_second_match) = indexes_dir1(match_level,bad_second_match);
%  second_match_dist1(bad_second_match)  = dists_dir1(2,bad_second_match);
%  
%  bad_second_match = keypoint_id1(first_match_index1) == keypoint_id1(second_match_index1);
%  match_level = match_level + 1;  
%end
%
%%The best match is always the nearest neighbor
%first_match_index2 = indexes_dir2(1,:);
%first_match_dist2  = dists_dir2(1,:);
%%Now find the second nearest neighbor that is not living at the same keypoint
%second_match_index2 = indexes_dir2(2,:);
%second_match_dist2 = dists_dir2(2,:);
%bad_second_match = keypoint_id2(first_match_index2) == keypoint_id2(second_match_index2);
%match_level = 3;
%while sum(bad_second_match) > 0
%  second_match_index2(bad_second_match) = indexes_dir2(match_level,bad_second_match);
%  second_match_dist2(bad_second_match)  = dists_dir2(2,bad_second_match);
%  bad_second_match = keypoint_id2(first_match_index2) == keypoint_id2(second_match_index2);
%  match_level = match_level + 1;  
%end


%Get the matches in direction 1 that pass the ratio test of distinctivness
matches_dir1_all = [1:size(first_match_index1,2); first_match_index1];
ratios1_all = (second_match_dist1./first_match_dist1);
passed_ratios1_indexes = find(ratios1_all > ratio_thresh);
ratios1 = ratios1_all(passed_ratios1_indexes);
matches_dir1 = matches_dir1_all(:,passed_ratios1_indexes);

%Get the matches in direction 1 that pass the ratio test of distinctivness
matches_dir2_all = [1:size(first_match_index2,2); first_match_index2];
ratios2_all = (second_match_dist2./first_match_dist2);
passed_ratios2_indexes = find(ratios2_all > ratio_thresh);
%ratios2 = ratios2_all(passed_ratios2_indexes);
matches_dir2 = matches_dir2_all(:,passed_ratios2_indexes);


%Get only the bidirectional matches
%This way both actual keypoints have to join test this against just keypoint locations
[matches, IA, ~] = intersect(matches_dir1', flipud(matches_dir2)','rows');
matches = fliplr(matches)';
%Give back score later
scores = ratios1(IA);
