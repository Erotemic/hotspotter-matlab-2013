%All Keypoints will be returned in the format [c;r;scale;ori] so keyoints will be 4xN
function [scaled_keypoints] = zebra_scale_detector(harris_keypoints, ScaleSpace, varargin)
global radius_per_scale;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Parse input arguments
%
display_on     = 0; %Controls Debug Display
scale_peak_neighborhood = 4;
scale_peak_thresh_percent = .7;
affine_invariant = 0;
for var_index = 1:size(varargin,2)
  var = varargin{var_index};
  if strcmp(var,'display_on')
    display_on = 1;
  end
  if strcmp(var,'display_off')
    display_on = 0;
  end
  if strcmp(var,'scale_peak_neighborhood')
    scale_peak_neighborhood = varargin{var_index+1};
  end
  if strcmp(var,'scale_peak_thresh_percent')
    scale_peak_thresh_percent = varargin{var_index+1};
  end
  if strcmp(var,'affine_invariant')
    affine_invariant = 1;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

I = ScaleSpace.I{1};
GImag = ScaleSpace.GIMag{1};
GIori = ScaleSpace.GIOri{1};
Gx = ScaleSpace.Gx{1};
Gy = ScaleSpace.Gy{1};

[rsize csize dim] = size(GImag);

min_radius = 2;
max_radius = 50;
radius_step = 1;
radii_to_search = min_radius:radius_step:max_radius;  

num_radii = size(radii_to_search,2);

%Allocate an expected amount of space for the harris keypoints + scales
scaled_keypoints = zeros(3,size(harris_keypoints,2)*4);
scaled_keypoint_index = 1;

for kp = harris_keypoints
  normalized_gradient_sums_unfiltered = zeros(num_radii,1);

  %Compute the maximum the radius can be for this keypoint
  %to make sure we don't go over bounds
  sample_radius = floor(min([max_radius+1, rsize-kp(2)+1, kp(2)-1, csize-kp(1)+1, kp(1)-1]));
  kp_max_radius = sample_radius - 1;
  kp_pxl = fix(kp);

  %Get a sampling of orientation, magnitude, and position
  sample_X = (kp_pxl(1)-sample_radius):(kp_pxl(1)+sample_radius);
  sample_Y = (kp_pxl(2)-sample_radius):(kp_pxl(2)+sample_radius);
  aoi_mag = GImag(sample_Y, sample_X);
  %aoi_I = I(sample_Y, sample_X);
  %aoi_Gx = Gx(sample_Y, sample_X);
  %aoi_Gy = Gy(sample_Y, sample_X);
  %aoi_center = [sample_radius+1 sample_radius+1]
  [aoi_X aoi_Y] = meshgrid(sample_X,sample_Y);
  
  %Find the distance from the keypoint to every pixel center
  x_dist = (aoi_X - kp(1));
  y_dist = (aoi_Y - kp(2));
  kp_dist = sqrt(x_dist.^2 + y_dist.^2);

  radius_index = 1;
  %Search through requested scales
  %to find ones that generate peaks in difference of
  %gradient magnitude histograms
  for r = radii_to_search

    %If the window goes outside the image bounds don't consider this scale
    if r > kp_max_radius 
      break 
    end

    %Find weights of pixels as to abuse subpixel accuracy
    %Get the pxl indexes of pixels within 1 distance of the keypoint

    inside_pxls  = find(kp_dist >= r - 1 & kp_dist < r);
    outside_pxls = find(kp_dist >= r     & kp_dist < r + 1);

    pxl_values = aoi_mag([inside_pxls; outside_pxls]);
    pxl_weights = [1 - (r - kp_dist(inside_pxls)); 1 - (kp_dist(outside_pxls) - r)];

    %Get the normalized sum around the edge of this circle of radius r
    normalized_gradient_sums_unfiltered(radius_index) = sum(pxl_values.*pxl_weights)/sum(pxl_weights);
    radius_index = radius_index + 1;
  end
  %Remove uncomputed values
  normalized_gradient_sums_unfiltered = normalized_gradient_sums_unfiltered(1:radius_index-1);

  %Smooth the sums before detecting peaks
  %TODO: vary size of smoothing with size of radii steps
  normalized_gradient_sums = imfilter(normalized_gradient_sums_unfiltered,fspecial('gaussian',[5 1],1.5));

  %Don't bother with points on an edge
  %The code should be robust enough to handle this check
  %being taken out
  if r > kp_max_radius
    %continue
  end

  %The peaks of the gradient magnitude sums as a function of radius length
  %are the scales that will be the most distinct

  %Find the peaks of the gradients at different scales ignoring the first and last few
  %Interpolate to the subpeak level
  invalid_peaks = [1:scale_peak_neighborhood radius_index-scale_peak_neighborhood:radius_index-1]';
  peak_indexes = peakfinder2(normalized_gradient_sums, scale_peak_neighborhood, scale_peak_thresh_percent,...
                            'invalid_peaks', invalid_peaks,...
                            'sub_peak_least_squares');

  if isempty(peak_indexes)
    sub_pixel_radii = [];
  else
    num_scales_found = size(peak_indexes,1);    
    %Convert the indexing scheme returned by peakfinder2 to a radius
    sub_pixel_radii = (peak_indexes-1) .* radius_step + min_radius;
    %Convert from radius to scale
    scale = (sub_pixel_radii./radius_per_scale)';
    %If there is not another space in the array add room for another scale
    if scaled_keypoint_index + num_scales_found > size(scaled_keypoints,2)
      scaled_keypoints = [scaled_keypoints zeros(3,size(harris_keypoints,1)*2)];
    end

    if affine_invariant
      for s = scale
        %Normally use 6sigma, but make sure we fit in the window
        %g_radius = min(ceil(6*s), sample_radius);
        %g_diamter = 2*g_radius+1;
        %radius_diff = sample_radius - g_radius;
        %g = zeros(size(aoi_Gx));
        %g(radius_diff+1:g_diamter+radius_diff,radius_diff+1:g_diamter+radius_diff) = fspecial('gaussian',[g_diamter,g_diamter],s);
        %Find the second moment matix at this point. Don't bother convolving.
        %We only need the answer at one pixel, just compute directly.
        %Ix2 = sum(sum(g.*(aoi_Gx.^2)));
        %Iy2 = sum(sum(g.*(aoi_Gy.^2)));
        %Ixy = sum(sum(g.*(aoi_Gx .* aoi_Gy)));
        %M = [Ix2 Ixy 0; Ixy Iy2 0; 0 0 1];
        %apply_homog_to_image(M^.5, aoi_I)
        %imshow(nzo(gaussfilt(aoi_I,s))); pause
        %Tranform the point to an affine invariant region
      end
    else
      %Just return the point detected at each scale
      scaled_keypoints(:,scaled_keypoint_index:(scaled_keypoint_index + num_scales_found - 1)) = [repmat(kp,[1, num_scales_found]); scale];
    end
    scaled_keypoint_index = scaled_keypoint_index + num_scales_found;
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Debugging Display
  if display_on
    figure(2);
    clf;
    imshow(norm_zero_one(ScaleSpace.I{1}));
    hold on;
    plot(harris_keypoints(1,:),harris_keypoints(2,:),'rx');
    plot(kp(1),kp(2),'bo');


    %Draw detected scales
    if ~isempty(peak_indexes)
      for radius = sub_pixel_radii'
        rectangle('Position',[kp(1)-radius,kp(2)-radius,radius*2,radius*2],'EdgeColor','k','Curvature', [1,1]);
      end
    end

    rectangle('Position',[kp(1)-r,kp(2)-r,r*2,r*2],'Curvature', [1,1],'EdgeColor','g');

    %Plot the normalized_gradient_sum curve
    figure(4);
    clf;
    plot(normalized_gradient_sums_unfiltered,'-k');
    hold on;
    title('Normalized sums of edge gradients');
    xlabel('Radius');
    ylabel('Normalized Sum of Weighted Edge Gradients');
    peakfinder2(normalized_gradient_sums, scale_peak_neighborhood, scale_peak_thresh_percent,...
                            'invalid_peaks', invalid_peaks,...
                            'sub_peak_least_squares',...
                            'figure',4);
    %Set the XTick Label to the radius instead of the index
    set(gca,'XTick',0:floor(4/radius_step):(radius_index-1));
    set(gca,'XTickLabel',((0:floor(4/radius_step):(radius_index-1))-1) .* radius_step + min_radius);
    pause;
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%Removed unused space
scaled_keypoints = scaled_keypoints(:,1:scaled_keypoint_index-1);
