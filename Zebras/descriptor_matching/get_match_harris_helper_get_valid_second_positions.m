%Helper function for get_match_harris
%
%Get the distance (kp space) of all canidate keypoints to all other close (descriptor space) 
%keypoints. Use the closest (descriptor space) keypoint that is outside a certain radius from
%the first canidate keypoint. The point of this is to get the indexes into indexes_dirX to 
%see which ones are the correct keypoints
%i to j
.................................................................
function [index_into_indexes_dirX] = get_match_harris_helper_get_valid_second_positions(fX,indexes_dirX)
  [num_searched_neighbors num_searched_kpts] = size(indexes_dirX);

  kp_x = reshape(fX(1,indexes_dirX),[num_searched_neighbors num_searched_kpts]);  % Get the xpositions of indexes_dirX
  kp_y = reshape(fX(2,indexes_dirX),[num_searched_neighbors num_searched_kpts]);  % Get the ypositions of indexes_dirX
  first_kp_x = repmat(kp_x(1,:),[num_searched_neighbors, 1]);
  first_kp_y = repmat(kp_y(1,:),[num_searched_neighbors, 1]);
  kp_dist_sqrd = (kp_x - first_kp_x).^2 + ...  % Get the kp-space dist from
                 (kp_y - first_kp_y).^2;       % the best match to all others
  [kpts_outside_radius_r, kpts_outside_radius_c] = find(kp_dist_sqrd > 100); % Find all the keypoints outisde the radius (r,c) positions into indexes_dir1
  %The find gives us the locations of all the keypoints
  %outside the radius, just first one in each column
  [~, last_unique_r_in_c , ~] = unique(kpts_outside_radius_c);
  %The unique operation gives us the last keypoint for each column
  %Just shift it around to get the first. %Holy long name batman.
  valid_kpts2best_kpts = [1; last_unique_r_in_c(1:end-1)+1];
  best_second_kp = kpts_outside_radius_r(valid_kpts2best_kpts);
  %We have indexes into the rows and the columns to which they belong
  %Change these into direct indexes so we can grab them all at once
  index_into_indexes_dirX = (0:num_searched_neighbors:num_searched_kpts*num_searched_neighbors-1)' + best_second_kp;
end
.................................................................

