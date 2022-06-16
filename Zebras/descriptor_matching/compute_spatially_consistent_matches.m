function [consistent_matches, consistent_indexes, H1, H2] = compute_spatially_consistent_matches(f1,f2,matches,ransac_dist_thresh,varargin)
global options 

display_on = 0;
for var_index = 1:size(varargin,2)
  var = varargin{var_index};
  if strcmp(var,'display_on')
    display_on = 1;
  end
  if strcmp(var,'display_off')
    display_on = 0;
  end
end

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

%Use the ransac algorithm to compute a transformations from img1 to img2
%and use the inliers as consistent matches. TODO: This algorithm should be done
%in regions later
sel_f1 = f1(:, matches(1,:));
sel_f2 = f2(:, matches(2,:));
%Grab a homogrphy matrix from img1 space to img2 space
[H1, best_inliers1] = ransac_homography(sel_f1,...
                                        sel_f2,...
                                        'DistThresh',ransac_dist_thresh,...
                                        'FilterOrientation',1);
[H2, best_inliers2] = ransac_homography(sel_f2,...
                                        sel_f1,...
                                        'DistThresh',ransac_dist_thresh,...
                                        'FilterOrientation',1);

consistent_indexes = intersect(best_inliers1,best_inliers2);
consistent_matches = matches(:,consistent_indexes);


if display_on
  Image1 = get_zebra(i);
  Image2 = get_zebra(j);

  %Apply homographies 
  [Image1_T, ~] = merge_images(H1, Image1, Image2);
  [Image2_T, ~] = merge_images(H2, Image2, Image1);

  BothImages1_T = CombineImages(Image1, Image2_T);
  BothImages2_T = CombineImages(Image2, Image1_T);

  f1_trans = apply_homog_to_points(H1, f1);
  f2_trans = apply_homog_to_points(H2, f2);

  % -- Figure 1
  % Display image 1 transformed into image 2 space as well 
  % as where features from image 1 exist in image 1 and image 2
  figure(options.figurenames.compute_match_debug);

  imshow(BothImages2_T);
  hold on
  title(['Image ' num2str(i) 'Features - G']);  
  f1_shift_vectors = zeros(size(f1_trans));
  f1_shift_vectors(2,:) = size(Image1,1);
  f1_trans_shifted = f1_trans + f1_shift_vectors;

  vl_plotframe(f2(:,matches(2,best_inliers1)),'LineWidth',1,'Color',[1 0 0]);
  vl_plotframe(f1_trans(:,matches(1,best_inliers1)),'LineWidth',1);
  vl_plotframe(f1_trans_shifted(:,matches(1,best_inliers1)),'LineWidth',1);
  draw_lines_between(f2(1:2,matches(2,best_inliers1)),f1_trans(1:2,matches(1,best_inliers1)),[1 0 0]);
  draw_lines_between(f2(1:2,matches(2,best_inliers2)),f1_trans(1:2,matches(1,best_inliers2)),[0 1 0]);
  draw_lines_between(f2(1:2,matches(2,consistent_indexes)),f1_trans(1:2,matches(1,consistent_indexes)),[0 0 1]);

  
  %plot(f1_trans(1,:),f1_trans(2,:),'rx')
  %plot(f1_trans_shifted(1,:),f1_trans_shifted(2,:),'rx')
  %plot(f1_trans(1,matches(1,best_inliers2)), f1_trans(2,matches(1,best_inliers2)),'bo');
  %plot(f1_trans_shifted(1,matches(1,best_inliers2)), f1_trans_shifted(2,matches(1,best_inliers2)),'bo');

  % We don't need to show the distance threshhold. It's pretty damn big
  %for kp = f1_trans 
  %  rectangle('Position',[kp(1)-.5-ransac_dist_thresh,kp(2)-.5-ransac_dist_thresh,ransac_dist_thresh*2+1,ransac_dist_thresh*2+1],'Curvature', [1,1],'EdgeColor','g') ;
  %end

  % -- Figure 2
  figure(options.figurenames.compute_match_debug+1);

  imshow(BothImages1_T);
  hold on
  title(['Image ' num2str(j) 'Features - G']);  
  f2_shift_vectors = zeros(size(f2_trans));
  f2_shift_vectors(2,:) = size(Image2,1);
  f2_trans_shifted = f2_trans + f2_shift_vectors;

  vl_plotframe(f1,'LineWidth',1,'Color',[1 0 0]);
  vl_plotframe(f2_trans,'LineWidth',1);
  vl_plotframe(f2_trans_shifted,'LineWidth',1);
  draw_lines_between(f1(1:2,matches(1,:)),f2_trans(1:2,matches(2,:)))
  %plot(f2_trans(1,:),f2_trans(2,:),'rx')
  %plot(f2_trans_shifted(1,:),f2_trans_shifted(2,:),'rx')
  %plot(f2_trans(1,matches(1,best_inliers2)), f2_trans(2,matches(1,best_inliers2)),'bo');
  %plot(f2_trans_shifted(1,matches(1,best_inliers2)), f2_trans_shifted(2,matches(1,best_inliers2)),'bo');

  % We don't need to show the distance threshhold. It's pretty damn big  
  %for kp = f2_trans 
  %  rectangle('Position',[kp(1)-.5-ransac_dist_thresh,kp(2)-.5-ransac_dist_thresh,ransac_dist_thresh*2+1,ransac_dist_thresh*2+1],'Curvature', [1,1],'EdgeColor','g') ;
  %end
  
end

