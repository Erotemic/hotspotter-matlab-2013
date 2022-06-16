function [oriented_keypoints] = keypoint_orientation_detector(scaled_keypoints, ScaleSpace, varargin)
global radius_per_scale;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Parse input arguments
%
display_on     = 0; %Controls Debug Display

for var_index = 1:size(varargin,2)
  var = varargin{var_index};
  if strcmp(var,'display_on')
    display_on = 1;
  end
  if strcmp(var,'display_off')
    display_on = 0;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GImag = ScaleSpace.GIMag{1};
GIori = ScaleSpace.GIOri{1};

%Preallocate space for the keypoints
oriented_keypoints = zeros(4,size(scaled_keypoints,2)*3);
oriented_keypoint_index = 1;

%Normalize to the range 1 to 36  (radians to peak indexes)
GIoriBinned = max(1,ceil(36.*((GIori+pi)./(2*pi))));
%Normalize to the ranoge 0 to 1
GImagZeroOne = GImag./255;

for kp = scaled_keypoints
  radius = kp(3)*radius_per_scale;
  int_radius = ceil(radius);
  %Grab the pixel locations of this radius's window
  window_r_range  = (round(kp(2))-int_radius):(round(kp(2))+int_radius);
  window_c_range  = (round(kp(1))-int_radius):(round(kp(1))+int_radius);

  %Create an orientation histogram of the window around this keypoint
  %weighted by a gaussian filter and it's magnitude using accumarray
  window_ori_bins = GIoriBinned(window_r_range,window_c_range);
  window_grad_mag = GImagZeroOne(window_r_range,window_c_range);
  %TODO once kps change to subpixel accuracy then this will need to change to shift the 
  %gaussian in the window
  ori_weights     = window_grad_mag .* fspecial('gaussian',2*int_radius + 1, radius./2);
  %  append dummy values with 0 weight to make sure there are 36 bins
  weighted_orientation_hist = accumarray([window_ori_bins(:); (1:36)'],[ori_weights(:); zeros(36,1)]');

  %TODO: We may be able to get rid of half of the keypoint detections because the 
  % matching algorithm only considers abs(dot products)
  weighted_orientation_hist = weighted_orientation_hist(1:18)+weighted_orientation_hist(19:end);

  %Smooth out the curve and add a bit of the tail to the head and visversa because 
  %this is a circle and the peaks should be detected as such. Remove extranious values later
  padding = 5; %Number of values to add at head and tail
  head_pad = weighted_orientation_hist(1:padding);
  tail_pad = weighted_orientation_hist(end-padding+1:end);
  weighted_orientation_hist_smooth = imfilter([tail_pad; weighted_orientation_hist; head_pad],[.2 .2 .2 .2 .2]);
  invalid_peaks = [1:padding size(weighted_orientation_hist,1)+padding+1:size(weighted_orientation_hist,1)+padding*2]';
  orientation_sub_peak_indexes_shifted = peakfinder2(weighted_orientation_hist_smooth, padding-1, .6,   ...
                                                 'invalid_peaks',invalid_peaks,...
                                                 'sub_peak_least_squares');

  orientation_sub_peaks_indexes = orientation_sub_peak_indexes_shifted - padding;
  
  %Convert from peak indexes to radians
  orientation_sub_peaks = ((orientation_sub_peaks_indexes./36)*2*pi)-pi;
  num_found_orient = size(orientation_sub_peaks,1);

   %If there is not another space in the array add room for another scale
  if oriented_keypoint_index + num_found_orient > size(oriented_keypoints,2)
    oriented_keypoints = [oriented_keypoints zeros(4,size(scaled_keypoints,1))];
  end
  oriented_keypoints(:,oriented_keypoint_index:(oriented_keypoint_index + num_found_orient - 1)) = [repmat(kp,[1, num_found_orient]); orientation_sub_peaks'];
  oriented_keypoint_index = oriented_keypoint_index + num_found_orient;



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Debugging Display
  if display_on
    figure(2)
    clf
    imshow(norm_zero_one(ScaleSpace.I{1}))
    hold on
    plot(scaled_keypoints(1,:),scaled_keypoints(2,:),'rx')
    plot(kp(1),kp(2),'bo')
    rectangle('Position',[kp(1)-radius,kp(2)-radius,radius*2,radius*2],'EdgeColor','g','Curvature', [1,1])   
    
    %theta = pi/9;
    for theta = orientation_sub_peaks'
      tmp_u = (radius+1) * cos(theta) ;
      tmp_v = (radius+1) * sin(theta) ;
      h = quiver(kp(1),kp(2),tmp_u,tmp_v,'Color',[0 1 0]);
      %set(gca, 'XLim', [1 10], 'YLim', [1 10]);
    end

    figure(4)
    clf
    plot([tail_pad; weighted_orientation_hist; head_pad],'-k')
    hold on
    title('Orientation Peaks');
    xlabel('Theta');
    ylabel('Weighted Orientation Responce');
    peakfinder2(weighted_orientation_hist_smooth, padding-1, .6,...
                                                 'invalid_peaks',invalid_peaks,...
                                                 'sub_peak_least_squares',...
                                                 'figure',4);

    stem(padding+1,max(weighted_orientation_hist)*1.3,'kd-')
    stem(size(weighted_orientation_hist,1)+padding,max(weighted_orientation_hist)*1.3,'kd-')
    set(gca,'XTick',1:5:size(weighted_orientation_hist,1)+padding*2)
    %set(gca,'XTickLabel',(1:5:size(weighted_orientation_hist,1)+padding*2)-padding) %Label for indexes
    set(gca,'XTickLabel',((((1:5:size(weighted_orientation_hist,1)+padding*2)-padding)./size(weighted_orientation_hist,1))*2*pi)-pi) %Label for radians
    pause
  end

  last_kp = kp;
end

%Removed unused space
oriented_keypoints = oriented_keypoints(:,1:oriented_keypoint_index-1);
