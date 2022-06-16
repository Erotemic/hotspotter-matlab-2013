%Look at i = 19
function [k, d] = harris_scale(I, varargin)
%Some code taken from kp_harris
global radius_per_scale;

display_on = 0;
enable_progress = 1;
keep_points_close_to_edge = 1;
for var_index = 1:size(varargin,2)
  var = varargin{var_index};
  if strcmp(var,'display_on')
    display_on = 1;
  end
  if strcmp(var,'display_off')
    display_on = 0;
  end
  if strcmp(var,'keep_points_close_to_edge')
    keep_points_close_to_edge = 1;
  end
  if strcmp(var,'disable_progress')
    enable_progress = 0;
  end
end


[rsize csize dim] = size(I);


%Compute the harris keypoints at multiple scales and 
%assign scales to them based on the expanding radius method
if enable_progress
  progress_handle = waitbar(0,'Harris Scale: Computing Harris Keypoints');
end
[harris_keypoints, ScaleSpace] = harris_keypoint_detector(I,'display_off','nonmax_radius',4,'nonmax_thresh',12);
if ~keep_points_close_to_edge
  indexes_of_close_to_edge_keypoints = max([harris_keypoints(1,:) < 50; harris_keypoints(1,:) > csize-50; harris_keypoints(2,:) < 50; harris_keypoints(2,:) > rsize-50]); 
  harris_keypoints = harris_keypoints(:,~indexes_of_close_to_edge_keypoints);
end
if enable_progress
  waitbar(.2, progress_handle, 'Harris Scale: Computing Scales');
end
[scaled_keypoints] = zebra_scale_detector(harris_keypoints, ScaleSpace,'display_off');
if enable_progress
  waitbar(.7, progress_handle, 'Harris Scale: Computing Orientations');
end
[oriented_keypoints] = keypoint_orientation_detector(scaled_keypoints, ScaleSpace,'display_off');

%Compute SIFT descriptors 
grd      = shiftdim(cat(3,ScaleSpace.GIMag{1},ScaleSpace.GIOri{1}),2) ;
grd      = single(grd) ;
d        = vl_siftdescriptor(grd, oriented_keypoints);
k        = oriented_keypoints;

if enable_progress
  waitbar(1, progress_handle, 'Harris Scale: Finished');
  close(progress_handle)
end

%End plotting stuff
if display_on
  global figurenames
  figure(figurenames.keypoints)
  clf
  ims how(norm_zero_one(ScaleSpace.I{1}))
  hold on
  
  index = 1;
  skipnum = 1;
  cm = hsv;
  for kp = oriented_keypoints(:,1:skipnum:end)
   radius = kp(3)*radius_per_scale;
   rectangle('Position',[kp(1)-radius,kp(2)-radius,radius*2,radius*2],'Curvature', [1,1],'EdgeColor','g') ;
   index = index + skipnum;
  end

  plot(oriented_keypoints(1,:),oriented_keypoints(2,:),'rx')  
  plot(oriented_keypoints(1,:),oriented_keypoints(2,:),'bo')  
end

