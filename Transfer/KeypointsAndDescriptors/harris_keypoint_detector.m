%All Keypoints will be returned in the format [c;r;scale;ori] so keyoints will be 4xN
function [harris_keypoints, ScaleSpace] = harris_keypoint_detector(I,varargin)
global options


%Make sure the input is a single grayscale image
if size(I,3) ~= 1
  disp('Warning: Input image is not black and white. Converting...');
  I = single(rgb2gray(I));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Parse input arguments
%
display_on     = 0; %Controls Debug Display
removal_radius = 0; %Removes Keypoints Within a Radius
num_scales     = 3; %Controls the number of 
use_old_method = 0;

nonmax_thresh = 12;
nonmax_radius = 4;


for var_index = 1:size(varargin,2)
  var = varargin{var_index};
  if strcmp(var,'display_on')
    display_on = 1;
  end
  if strcmp(var,'display_off')
    display_on = 0;
  end
  if strcmp(var,'removal_radius')
    error('This has been depreciated. remove this message if you really care');
    removal_radius = varargin{var_index+1};
  end
  if strcmp(var,'nonmax_radius')
    nonmax_radius = varargin{var_index+1};
  end
  if strcmp(var,'nonmax_thresh')
    nonmax_thresh = varargin{var_index+1};
  end
  if strcmp(var,'keep_points_close_to_edge')
    keep_points_close_to_edge = 1;
  end
  if strcmp(var,'num_scales')
    num_scales = 1;
  end
  if strcmp(var,'use_old_method')
    use_old_method = 1;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



sigma = .5; %Sigma for scale space

L = gaussfilt(I,sigma);

%TODO: Create an octavelike sort of representation
%      And find harris corners that are maxima in scalespace
%      as well as spatially 
%Create a pyramid in scale space
ScaleSpaceI = cell(1,num_scales);
ScaleSpaceI{1} = L;
for scale_index = 2:num_scales
  %Because I*G(4s) = downsample(I*G(2s))*G(2s)
  %Convolving a scaled down image with the same kernel
  %will replicate a larger sigma in scale space
  L = gaussfilt(L(1:2:end,1:2:end),sigma);
  ScaleSpaceI{scale_index} = L;
end

harris_keypoints_at_scale = [];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% New Algorithm using Peter Koveski's Fucntions
% This should be a bit more stable than the 
% way I was computing harris keypoints
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~use_old_method

  
  for scale_index = 1:num_scales
    L = ScaleSpaceI{scale_index};
    
    %Add the new keypoints and the scales they were found at (also resizes keypoints back to original scale)
    image_scale = 2^(scale_index-1); 

    sigma_I = .5;

    %Get harris keypoints to subpixel accuracy 
    [~, ~, ~, r, c] = harris(L, sigma_I, nonmax_thresh, nonmax_radius);

    keypoints_to_add = [c r]'.*(image_scale);

    if scale_index > 1 & ~isempty(harris_keypoints_at_scale)
      %Before adding new keypoints check to make sure a close keypoint was not added at a larger scale
      %If it was defer to the keypoints at the larger scale. TODO this could be changed to defer to the 
      %Better keypoint, but just doing larger should be consistent and not make that much difference
      
      [~, distances] = knnsearch(harris_keypoints_at_scale(1:2,:)',keypoints_to_add','K',1);
      surviving_keypoints = distances > nonmax_radius;
      keypoints_to_add = keypoints_to_add(:, surviving_keypoints);
    end

    harris_keypoints_at_scale = [harris_keypoints_at_scale [ keypoints_to_add; repmat(image_scale*sigma,1,size(keypoints_to_add,2))] ];

    %Return image derivatives if requested
    if nargout >= 2
      if ~exist('ScaleSpaceGx','var')
        ScaleSpaceGx = cell(1,num_scales);
        ScaleSpaceGy = cell(1,num_scales);
        ScaleSpaceGIMag = cell(1,num_scales);
        ScaleSpaceGIori = cell(1,num_scales);
      end
      [Ix, Iy] = derivative5(L, 'x', 'y');
      ScaleSpaceGx{scale_index} = Ix;
      ScaleSpaceGy{scale_index} = Iy;
      ScaleSpaceGIMag{scale_index} = sqrt(Ix.^2 + Iy.^2);
      ScaleSpaceGIOri{scale_index} = atan2(double(Iy),double(Ix));
    end
  end

else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Old Algorithm. Replaced by Peter Koveski's Functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute the cornerness measure for each scale
for scale_index = 1:num_scales
  L = ScaleSpaceI{scale_index};

  %Compute derivative kernels 
  sigma_D = 0.7*sigma; %Differentiation Sigma
  x  = -round(3*sigma_D):round(3*sigma_D);
  dx = x .* exp(-x.*x/(2*sigma_D^2)) ./ (sigma_D^3 * sqrt(2*pi));
  dy = dx';


  % image derivatives
  GIx = imfilter(L, dx, 'replicate');
  GIy = imfilter(L, dy, 'replicate');


  %Return image derivatives if requested
  if nargout >= 2
    if ~exist('ScaleSpaceGx','var')
      ScaleSpaceGx = cell(1,num_scales);
      ScaleSpaceGy = cell(1,num_scales);
      ScaleSpaceGIMag = cell(1,num_scales);
      ScaleSpaceGIori = cell(1,num_scales);
    end
    ScaleSpaceGx{scale_index} = GIx;
    ScaleSpaceGy{scale_index} = GIy;
    ScaleSpaceGIMag{scale_index} = sqrt(GIx.^2 + GIy.^2);
    ScaleSpaceGIOri{scale_index} = atan2(double(GIy),double(GIx));
  end


  % Compute the components of the Harris Auto-Correlation Matrix  
  sigma_I = .5; %Sigma Integration  
  g_window_integration = max(1,floor(6*sigma+1));
  g_integration = fspecial('gaussian',g_window_integration,sigma_I);
  Ix2 = imfilter(GIx.^2,   g_integration, 'replicate'); 
  Iy2 = imfilter(GIy.^2,   g_integration, 'replicate');
  Ixy = imfilter(GIx.*GIy, g_integration, 'replicate');


  %Compute the harris cornerness measure (Finds places where both
  %eigenvalues of the Auto-Correlation Matrix are large)
  k = 0.16;
  cim = (Ix2.*Iy2 - Ixy.^2) - k*(Ix2 + Iy2).^2;


  %Remove any cornerness detected around a boundary
  border_width = round(size(L,1)*.05);
  cim(1:border_width,:) = 0;
  cim(:,1:border_width) = 0;
  cim(end-border_width:end,:) = 0;
  cim(:,end-border_width:end) = 0;


  % find local maxima on 3x3 neighborgood
  [r,c,max_local_zeros] = findLocalMaximum(cim,3*sigma);


  % set threshold 1% of the maximum value
  max_local = sort(max_local_zeros(max_local_zeros ~= 0)) ;


  %Get the mean and variance of the local values in a neighborhood
  %Set the threshold to a percentage of the maximum stable (not a lot of variance) local max
  max_local_neighborhood_mean = imfilter(max_local,[.2;.2;.2;.2;.2],'replicate');
  max_local_squared_neighborhood_mean = imfilter(max_local.^2,[.2;.2;.2;.2;.2],'replicate');
  max_local_neighborhood_var = max_local_squared_neighborhood_mean - max_local_neighborhood_mean.^2;
  %TODO: Find a way to automatically compute the '10' value threshold
  t = .15*max(max_local(max_local_neighborhood_var < 10));

  % find local maxima greater than threshold
  [r c] = find(max_local_zeros>=t);
  %Add the new keypoints and the scales they were found at (also resizes keypoints back to original scale)
  image_scale = 2^(scale_index-1); 
  harris_keypoints_at_scale = [harris_keypoints_at_scale [ [c r]'.*(image_scale); repmat(image_scale*sigma,1,size(r,1))] ];
end

end

..............................................................................................................
... End of Main Algorithm

%Return scale space if requested
if nargout >= 2
  ScaleSpace.num_scales = num_scales;
  ScaleSpace.initial_sigma = sigma;
  ScaleSpace.I     = ScaleSpaceI;
  ScaleSpace.Gx    = ScaleSpaceGx;
  ScaleSpace.Gy    = ScaleSpaceGy;
  ScaleSpace.GIMag = ScaleSpaceGIMag;
  ScaleSpace.GIOri = ScaleSpaceGIOri;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Remove keypoints that are too close to each other
%  TODO: Keep scale in this computation
if removal_radius ~= 0
  harris_keypoints_filtered = unique(round(harris_keypoints_at_scale(1:2,:)'),'rows')';

  %Remove all points that are too close to each other
  [neighbors2 distances] = knnsearch(harris_keypoints_filtered,harris_keypoints_filtered,'K',2);
  distances = distances(:,2);
  while min(distances) < removal_radius & size(harris_keypoints_filtered,1) > 0
    neighbors1 = (1:size(harris_keypoints_filtered,1))';
    neighbors2 = neighbors2(:,2);
    
    %make sure we don't remove both points if they are close to each other
    to_remove = unique(sort([neighbors1(distances < removal_radius) neighbors2(distances < removal_radius)]')','rows');
    to_remove = to_remove(:,1);

    to_keep = setdiff((1:size(harris_keypoints_filtered))',to_remove);
    harris_keypoints_filtered = harris_keypoints_filtered(to_keep,:);
   
    %Catch rare errors where there is only one keypoints left
    if size(harris_keypoints_filtered,1) == 1
      disp('Filtered out all but one keypoints make sure everything is ok')
      break
    end
    [neighbors2 distances] = knnsearch(harris_keypoints_filtered,harris_keypoints_filtered,'K',2);
    distances = distances(:,2);
  end  
  harris_keypoints = harris_keypoints_filtered;

  %Just place to put quick plotting info for debugging
  if 0
    imshow(norm_zero_one(I))
    hold on
    plot(harris_keypoints_at_scale(1,:),harris_keypoints_at_scale(2,:),'rx');
    plot(harris_keypoints_filtered(1,:),harris_keypoints_filtered(2,:),'gx');
    return 
  end

else
  %TODO: Keep Keypoint Scale
  harris_keypoints = unique((harris_keypoints_at_scale(1:2,:)'),'rows')';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if display_on
  figure(options.figurenames.keypoints)
  clf
  imshow(norm_zero_one(I))
  hold on
  plot(harris_keypoints(1,:),harris_keypoints(2,:),'ko')  
  %plot(harris_keypoints(1,:),harris_keypoints(2,:),'rx')

  cm = hsv;... colormap('hsv');
  all_scales = unique(harris_keypoints_at_scale(3,:));
  color_index = 1;
  for s = all_scales 
    plot_color = cm(floor(size(cm,1)/3)*color_index,:);
    plot_color
    plot(harris_keypoints_at_scale(1,harris_keypoints_at_scale(3,:)==s),harris_keypoints_at_scale(2,harris_keypoints_at_scale(3,:)==s),'x','Color',plot_color)
    color_index = color_index + 1;
  end 

  %plot(harris_keypoints_at_scale(1,harris_keypoints_at_scale(3,:)==1),harris_keypoints_at_scale(2,harris_keypoints_at_scale(3,:)==1),'gx')

  %plot(harris_keypoints_at_scale(1,harris_keypoints_at_scale(3,:)==.5),harris_keypoints_at_scale(2,harris_keypoints_at_scale(3,:)==.5),'rx')
end


if 0
  for i = 1:500
    I = get_zebra(i); harris_keypoint_detector(I,'display_on','nonmax_radius',3,'nonmax_thresh',10); pause
  end
end
