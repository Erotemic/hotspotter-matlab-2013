 
% i = 27; j = 29; load_mad_debug_info;
%i = 1; j = get_matching_gts(i); load_mad_debug_info;
%i = 12; j = 16;  load_mad_debug_info;
%i = 16; j = 15; load_mad_debug_info;
%i = 40; j = 36; load_mad_debug_info;

  f1 = query_property(i,-1,'keypoints',varargin);
  f2 = query_property(j,-1,'keypoints',varargin);
  d1 = query_property(i,-1,'descriptors');
  d2 = query_property(j,-1,'descriptors');
  
  [raw_matches, raw_scores] = get_match_harris(i, j, f1, f2,single(d1), single(d2), varargin);
  
  matches = raw_matches;

  
  img1 = get_zebra(i);
  img2 = get_zebra(j);
    Image1 = get_zebra(i);
  Image2 = get_zebra(j);
  
  ransac_dist_thresh = min(size(img2,1),size(img1,2))*.2;


  sel_f1 = f1(:, matches(1,:));
  sel_f2 = f2(:, matches(2,:));


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


  f1_trans = apply_homog_to_points(H1, f1);
  f2_trans = apply_homog_to_points(H2, f2);

  f1_shift_vectors = zeros(size(f1_trans));
  f1_shift_vectors(2,:) = size(Image1,1);


  
  %Give each consistent match a local anticonsistency score
  local_anticonsistency_sum   = zeros(size(consistent_matches(1,:)));
  local_anticonsistency_votes = zeros(size(consistent_matches(1,:)));

  %WORKING IN THIS FUNCTION !!!!
  for const_match = consistent_matches

    
    %AOI_1 = 
    %AOI_2 = Image2(floor(f2(2,const_match(2))-ransac_dist_thresh):ceil(f2(2,const_match(2))+ransac_dist_thresh), floor(f2(1,const_match(2))-ransac_dist_thresh):ceil(f2(1,const_match(2))+ransac_dist_thresh))

    %i2aoi = [
    %Get all local neighbors within a radius 
    [neighbor_indexes, neighbor_dist]  = knnsearch(f2(1:2,consistent_matches(2,:))',f2(1:2,const_match(2))','K',10);
    local_neighbors = neighbor_indexes(neighbor_dist < (ransac_dist_thresh/2));

    local_f1 = f1(:,consistent_matches(1,local_neighbors));
    local_f2 = f2(:,consistent_matches(2,local_neighbors));


    local_translation = f2(1:2,const_match(2)) - f1(1:2,const_match(1));
    local_scale       = f2(3,const_match(2)) / f1(3,const_match(1));    
    local_rotation    = f2(4,const_match(2)) - f1(4,const_match(1));

    A_trans_center = [1 0 -f1(1,const_match(1));...
                      0 1 -f1(2,const_match(1));...
                      0 0 1];

    A_trans_back =   [1 0 f2(1,const_match(2));...
                      0 1 f2(2,const_match(2));...
                      0 0 1];

   % A_trans = [1 0 local_translation(1);...
   %            0 1 local_translation(2);...
   %            0 0 1];

    A_rot   = [cos(local_rotation) -sin(local_rotation) 0 ;...
               sin(local_rotation)  cos(local_rotation) 0 ;...
               0                    0                   1];

    A_scale = [local_scale      0      0 ;...
               0           local_scale 0 ;...
               0                0      1];

    %Compose affine matrixes together to get transformation at point
   % A = A_scale * A_rot * A_trans;

    A = A_trans_back * A_scale * A_rot * A_trans_center;

    %Get transformation from image 1 to image 2
    [Image1_TA, ~] = merge_images(A,      Image1, Image2);
    [Image2_TA, ~] = merge_images(inv(A), Image2, Image1);
    BothImages2_TA = CombineImages(Image2, Image1_TA);

    f1_trans_A = apply_homog_to_points(A, f1);

    %These should be equal 
    f1_trans_A_shifted = f1_trans_A + f1_shift_vectors;
   
    figure(1);

    imshow(BothImages2_TA);
    
    %if 0
    %Plot things in Image2
    vl_plotframe(f2(:,consistent_matches(2,local_neighbors)),'Color',[1 .5 .5],'LineWidth',1);    
    vl_plotframe(f2(:,const_match(2)),'Color',[1 0 0],'LineWidth',2);

    vl_plotframe(f1_trans_A(:,consistent_matches(1,local_neighbors)),'Color',[.5 1 .5],'LineWidth',1);   
    
    %Plot things in Image1_TA
    vl_plotframe(f1_trans_A_shifted(:,consistent_matches(1,local_neighbors)),'Color',[.5 1 .5],'LineWidth',1);   
    vl_plotframe(f1_trans_A_shifted(:,const_match(1)),'Color',[0 1 0],'LineWidth',2);
    %end

    draw_lines_between(f2(:,consistent_matches(2,local_neighbors)),f1_trans_A(:,consistent_matches(1,local_neighbors)),[0 0 1]);
    

    dist_diff_sqrd  = sqrt(sum( (f1_trans_A(1:2,consistent_matches(1,local_neighbors)).^2 - f2(1:2,consistent_matches(2,local_neighbors))).^2 ));
    local_anticonsistency_sum(local_neighbors) = local_anticonsistency_sum(local_neighbors) + dist_diff_sqrd;
    local_anticonsistency_votes(local_neighbors) = local_anticonsistency_votes(local_neighbors) + 1;

    figure(2);
    clf
    plot(local_anticonsistency_sum)
    hold on
    plot(local_neighbors,local_anticonsistency_sum(local_neighbors),'ro')


    %imshow(BothImages2_T);
    %[neighbor_indexes, neighbor_dist]  = knnsearch(f2(1:2,consistent_matches(2,:))',f2(1:2,const_match(2))','K',10);
    %vl_plotframe(f2(:,consistent_matches(2,neighbor_indexes(neighbor_dist < ransac_dist_thresh))),'Color',[1 .5 .5]);    
    %vl_plotframe(f2(:,const_match(2)),'Color',[1 0 0]);
    %vl_plotframe(f1_trans(:,const_match(1)));


    %vl_plotframe(f1_trans_shifted(:,consistent_matches(1,neighbor_indexes(neighbor_dist < ransac_dist_thresh))),'Color',[.5 1 .5]);    
    %vl_plotframe(f1_trans_shifted(:,const_match(1)));
    %vl_plotframe(f2(:,const_match(2))+[0; size(Image1,1); 0; 0],'Color',[1 0 0]);
    
    pause
  end

  %figure
  %plot(local_anticonsistency_sum./local_anticonsistency_votes)

