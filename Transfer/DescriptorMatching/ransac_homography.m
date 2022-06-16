function [H, inliers] = ransac_homography(sel_f1,sel_f2,varargin)

if size(varargin,2) == 1
    ransac_dist_thresh = varargin{1};
end

[unique_f1, uf1_I, uf1_J] = unique(sel_f1(1:2,:)','rows');
[unique_f2, uf2_I, uf2_J] = unique(sel_f2(1:2,:)','rows');


filter_orientation = 1;
filter_scale = 1;
for vari = 1:size(varargin,2)
  if strcmp(class(varargin{vari}),'char') & strcmp(varargin{vari},'FilterOrientation')
    filter_orientation = varargin{vari+1};
  end
  if strcmp(class(varargin{vari}),'char') & strcmp(varargin{vari},'FilterScale')
    filter_scale = varargin{vari+1};
  end
  if strcmp(class(varargin{vari}),'char') & strcmp(varargin{vari},'DistThresh')
    ransac_dist_thresh_sqrd = varargin{vari+1}.^2; %Square the distance threhhold 
  end
end

num_unique_matches = size(unique_f1,1);
inliers = [];
if num_unique_matches < 4 | size(unique_f2,1) < 4
  H = eye(3);
  best_inliers = [];
  trans_sel_f1 = [];
  return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Use RANSAC to generate inlier points
%  (random sample consensus)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
best_inliers = [];
best_H = eye(3);
best_kpts = [];
for ransac_times = 1:512
  %Generate a homog from 4 random points
  rsel_unique = randperm(num_unique_matches);
  rsel_unique = rsel_unique(1:4);

  %Out of the unique points (ie no same scale and orientation) 
  %find 4 unique points that match
  rsel = zeros(4,1);
  rsel_index = 1;
  for rand_unique_index = rsel_unique
    %Pick a 4 unique points and then randomly pick one of the scale/orientations 
    %from each of the 4 points. 
    rsel_all = find(uf1_J == rand_unique_index);
    rsel(rsel_index) = rsel_all(ceil(rand(1)*size(rsel_all,1)));
    rsel_index = rsel_index + 1;
  end

  %If we matched two random points to the same point this 
  %homography will be no good
  if size(unique(sel_f2(:,rsel)','rows'),1) ~= 4
    continue
  end

  Hprime = generate_homog(sel_f1(1:2,rsel), sel_f2(1:2,rsel));
  %Change f1 coordinates to f2 coordinates
  trans_f1 = apply_homog_to_points(Hprime, sel_f1);

  %Get the squared distance between each transformed point
  %and it's match
  dist_diff  = sum( (trans_f1(1:2,:) - sel_f2(1:2,:)).^2 );

  %Get the difference in the angles
  big_theta = max(trans_f1(4,:)+pi, sel_f2(4,:)+pi);
  little_theta = min(trans_f1(4,:)+pi, sel_f2(4,:)+pi);
  theta_diff = min(big_theta - little_theta, 2*pi - big_theta + little_theta);

  %Conditions for an inlier are ...
  tenative_inliers = find(dist_diff  < ransac_dist_thresh_sqrd & ... Be somewhere close to the original point
                 trans_f1(3,:) > sel_f2(3,:)./2 &  trans_f1(3,:) < sel_f2(3,:).*2 & ... Be in a factor of 2 of scale
                 theta_diff < pi/3 ... Be within 60 degress of orientation
                 );
  
  %If this has more inliers use it
  if ( size(best_inliers,2) < size(tenative_inliers,2) )
    best_H = Hprime;
    best_kpts = rsel;
    best_inliers = tenative_inliers;
  end
end

trans_f1 = apply_homog_to_points(best_H, sel_f1);
%debug_ransac;


%If we didn't compute anything return bad results
if isempty(best_inliers)
  H = eye(3);
  return
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
[norm_f1, T1] = prehomog_normalize_points(sel_f1(1:2,best_inliers));
[norm_f2, T2] = prehomog_normalize_points(sel_f2(1:2,best_inliers));

if sum(sum(isnan(norm_f2))) > 0 | sum(sum(isnan(norm_f1))) > 0
  H = eye(3);
  best_inliers = [];
  return
end
%Create an overconstrained homography from the inliers
%and then normalize it
H_prime = generate_homog(norm_f1,norm_f2);
H = T2\H_prime*T1;


%Generate a final set of inliers
%Change f1 coordinates to f2 coordinates
trans_f1 = apply_homog_to_points(H, sel_f1);

%Get the squared distance between each transformed point
%and it's match
dist_diff  = sum( (trans_f1(1:2,:) - sel_f2(1:2,:)).^2 );

%Get the difference in the angles
big_theta    = max(trans_f1(4,:)+pi, sel_f2(4,:)+pi);
little_theta = min(trans_f1(4,:)+pi, sel_f2(4,:)+pi);
theta_diff   = min(big_theta - little_theta, 2*pi - big_theta + little_theta);

inliers = find(dist_diff  < ransac_dist_thresh_sqrd & ... Be somewhere close to the original point
               trans_f1(3,:) > sel_f2(3,:)./2 &  trans_f1(3,:) < sel_f2(3,:).*2 & ... Be in a factor of 2 of scale
               theta_diff < pi/3 ... Be within 60 degress of orientation
               );
