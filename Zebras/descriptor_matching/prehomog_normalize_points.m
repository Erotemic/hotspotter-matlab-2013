function [norm_x1, T1] = prehomog_normalize_points(bestx1)

%Homogonize coordinates if they are not already
if size(bestx1,1) == 2
  bestx1 = [bestx1; ones(1,size(bestx1,2))];
end

%Compute the center of mass
num_inliers = size(bestx1,2);
centers = sum(bestx1,2)./num_inliers;

%Compute the average pixel position magnitude
magi = sum(abs(bestx1(1,:)-centers(1))) / num_inliers;
magj = sum(abs(bestx1(2,:)-centers(2))) / num_inliers;

%Create normilization matrix
%Scale and translation
T1 = [1/magi 0      -centers(1)/magi;
      0      1/magj -centers(2)/magj;
      0      0      1];

norm_x1 = T1*bestx1;
