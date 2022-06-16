%function [] = matching_experiment_click_debugger()
global matching_experiment_i
global matching_experiment_j
global options
global selected_kp1
global selected_kp2
global radius_per_scale;

  if ~exist('scale1','var')
    scale1 = 1;
    orient1 = 1;
    scale2 = 1;
    orient2 = 1;
  end

  fprintf([...
'\n' ...
'Image1:\n' ...
'  scale1=%d:\n' ...
'  orient1=%d:\n' ...
'Image2:\n' ...
'  scale2=%d:\n' ...
'  orient2=%d:\n'], scale1,orient1,scale2,orient2);

  
  i = matching_experiment_i;
  j = matching_experiment_j;
  if isempty(i) | isempty(j)
    return
  end
  %This is a function for getting specific info from a matching experiment

  experiment_figure = 2;
  figure(experiment_figure);

  %Have the user click a point in the experiment figure
  disp('Click Point1')
  [x,y] = ginput(1)
  disp(['Point Clicked: (' num2str(x) ', ' num2str(y) ')'])

  %Have the user click a point in the experiment figure
 % disp('Click Point2')  
 % [x,y] = ginput(1);
 % disp(['Point Clicked: (' num2str(x) ', ' num2str(y) ')'])

  %------------------------------------------------------------   
  %Get information computed in the experiment see comments there
  %Populate selected_matches with the matches you want to display
  if options.show_raw_matches == 0
    [selected_matches, selected_scores] = get_computed_match(i,j);
  else
    [~, ~, selected_matches, selected_scores] = get_computed_match(i,j);
  end
  Image1 = get_zebra(i);
  Image2 = get_zebra(j);
  [r1 c1 tmpdim] = size(Image1);
  [r2 c2 tmpdim] = size(Image2);
  row = r1+r2;
  col = max(c1,c2);
  BothImages = uint8(zeros(row,col,tmpdim));
  BothImages(1:r1,1:c1,:) = Image1;
  BothImages(r1+1:row,1:c2,:) = Image2;
  f1 = query_property(i,-1,'keypoints');
  d1 = query_property(i,-1,'descriptors');
  f2 = query_property(j,-1,'keypoints');
  f2_shifted = f2 + repmat([0;r1;0;0],[1,size(f2,2)]);   
  d2 = query_property(j,-1,'descriptors');
  %If on only keypoints and descriptors of matches are drawn
  if isfield(options,'showallkeypoints') & options.showallkeypoints == 1
    d1 = d1;
    d2 = d2;
    f1 = f1;
    f2_shifted = f2_shifted;
  else
    if ~isempty(selected_matches)
      d1 = d1(:,selected_matches(1,:));
      d2 = d2(:,selected_matches(2,:));
      f1 = f1(:,selected_matches(1,:));
      f2_shifted = f2_shifted(:,selected_matches(2,:));
    end
  end
  %------------------------------------------------------------

  %Check to see if the click was in image2 or image 1
  clicked_in_img2 = y > r1

  if ~clicked_in_img2
    fig_num = options.figurenames.click_debugger;
    selected_keypoints = f1;
  else
    fig_num = options.figurenames.click_debugger+1;
    selected_keypoints = f2_shifted;
  end
  
  [idx, dist] = knnsearch(selected_keypoints(1:2,:)',[x,y],'K',10);

  idx = idx(dist == dist(1));
  dist = dist(dist == dist(1));

  run_matching_experiment(i,j);

  hold on
  %Show the keypoints you selected
  keypoints_handle = vl_plotframe(selected_keypoints(:,idx)) ; 
  set(keypoints_handle,'color','r','linewidth',.5);

  selected_keypoints(:,idx)

  max_radius = max(selected_keypoints(3,idx)*radius_per_scale);
  kp_center = selected_keypoints(:,idx(1));

  r_range = ceil(kp_center(2)+.5)-ceil(max_radius)-1:ceil(kp_center(2)+.5)+ceil(max_radius)
  c_range = ceil(kp_center(1)+.5)-ceil(max_radius)-1:ceil(kp_center(1)+.5)+ceil(max_radius)

  x_offset = c_range(1)-1;
  y_offset = r_range(1)-1;

  figure(fig_num)
  clf
  imshow(BothImages(r_range,c_range,:))
  hold on

  for kp = selected_keypoints(:,idx)
    radius = kp(3)*radius_per_scale;  
    rectangle('Position',[kp(1)-radius-x_offset,kp(2)-radius-y_offset,radius*2,radius*2],'EdgeColor','g','Curvature', [1,1])   

    tmp_u = (radius+1) * cos(kp(4)) ;
    tmp_v = (radius+1) * sin(kp(4)) ;
    h = quiver(kp(1)-x_offset,kp(2)-y_offset,tmp_u,tmp_v);
  end
  
