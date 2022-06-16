%Expects points in [x; y; scale; theta] format. 
function [points_trans] = apply_homog_to_points(H, points)

  %Add the homoginizeing dimension w of all ones to start out with 
  w = ones(1,size(points,2));
  %Apply the homography. This will cause w to become non 1 (an unhomoginized matrix)
  trans_points_unhomoginized = H * [points(1:2,:); w];
  %Divide by the new w to get back to all w's = 1. This results in points in the new coordinate system
  trans_points_homoginized = trans_points_unhomoginized(1:2,:) ./ repmat(trans_points_unhomoginized(3,:),[2,1]);

  points_trans = trans_points_homoginized;

  %points is more than just x,y positions orientation and scale also exist transform those as well
  if size(points,1) == 4
    %Get points which are scale distance away at a theta angle from 
    %the original point
    ori_points = [points(1,:) + points(3,:).*cos(points(4,:));...
                  points(2,:) + points(3,:).*sin(points(4,:));...
                  ones(1,size(points,2))];
    trans_ori_points_unhomoginized = H * ori_points;
    trans_ori_points_homoginized = trans_ori_points_unhomoginized(1:2,:) ./ repmat(trans_ori_points_unhomoginized(3,:),[2,1]);

    direction_vector_unnormalized = trans_ori_points_homoginized - trans_points_homoginized;
    [direction_vector_normalized, trans_scale] = normalize_vector_list(direction_vector_unnormalized);
    trans_orientation = atan2(direction_vector_normalized(2,:),direction_vector_normalized(1,:));

    points_trans = [points_trans(1:2,:); trans_scale; trans_orientation];
  end


