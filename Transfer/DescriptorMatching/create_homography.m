function [H, best_inliers] = ransac_homography(x1,x2,varargin)

if size(varargin,2) == 1
    ransac_dist_thresh = varargin{1};
end
nmatches = size(x1,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Use RANSAC to generate inlier points
%  (random sample consensus) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
best_inliers = [];
best_H = [];
best_kpts = [];
for ransac_times = 1:500
  %Generate a homog from 4 random points
  rsel = randperm(nmatches);
  rsel = rsel(1:4);
  x1s = x1(:,rsel);
  x2s = x2(:,rsel);
  Hprime = generate_homog(x1(:,rsel), x2(:,rsel));
  %Change x1 coordinates to x2 coordinates
  tx1 = Hprime*x1;
  trans_x1 = tx1./repmat(tx1(3,:),3,1);
  %Get the squared distance between each transformed point
  %and it's match
  distances = (trans_x1(1,:) - x2(1,:)).^2 + (trans_x1(2,:) - x2(2,:)).^2;
  %Get the indexes of the points that met the threshhold
  inliers = find(distances < ransac_dist_thresh);
  %If this has more inliers use it
  if ( size(best_inliers,2) < size(inliers,2)) 
    best_H = Hprime;
    best_kpts = rsel;
    best_inliers = inliers;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get a homography
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%H maps from x1 to x2
%inv(H) maps from x2 to x1

%We now have the best inliers. To compute the best homography
%Normalize 
num_inliers = size(best_inliers,2);
[norm_x1, T1] = prehomog_normalize_points(x1(:,best_inliers));
[norm_x2, T2] = prehomog_normalize_points(x2(:,best_inliers));

%Create a homography from the inliers
%and then normalize it
H_prime = generate_homog(norm_x1,norm_x2);
H = inv(T2)*H_prime*T1;
