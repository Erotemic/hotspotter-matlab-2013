max_radius = 8;

%Set up a checkerboard enough size to fit a circle of max_radius
CB_radius = max_radius+1;
CB = checkerboard(1,CB_radius+1,CB_radius+1); CB = CB(1:end-1,1:end-1); CB(CB > 0) = 1; CB = repmat(CB,[1 1 3]);


%Plot a keypoint and find the scale weighting around it
kp = [.5, .5];
kp_fix = fix(kp);
kp_offset = kp - kp_fix;
kp_debug = kp_offset + CB_radius + 1;


%Get the distance from the keypoint to the center of each pixel around it
[X Y] = meshgrid(1:(CB_radius*2+1),1:(CB_radius*2+1));
XDIST = (X - CB_radius - 1 - kp_offset(1)); %XDistance to center of pixel
YDIST = (Y - CB_radius - 1 - kp_offset(2)); %YDistance to center of pixel
DISTSQRD = XDIST.^2 + YDIST.^2
DIST = sqrt(DISTSQRD); %Total distance to center of pixel


for radius = 0:.1:max_radius
  radius
  %Set up display stuff
  TOSHOW_R = CB(:,:,1)./2;
  TOSHOW_G = CB(:,:,2)./2;
  TOSHOW_B = CB(:,:,3)./2;

  %Find which pixels are inside pixels and which are outside
  INSIDE = DIST >= radius-1 & DIST < radius;
  OUTSIDE = DIST >= radius & DIST < radius+1;

  inside_dist = DIST-radius; inside_dist(~INSIDE) = 0;
  outside_dist = DIST-radius; outside_dist(~OUTSIDE) = 0;

  inside_weight = 1 - radius + DIST; inside_weight(~INSIDE) = 0;
  outside_weight = 1 - DIST + radius; outside_weight(~OUTSIDE) = 0;


 % inside_weight = 

  %Show STuff
  TOSHOW_R(OUTSIDE) = 1;
  TOSHOW_B(INSIDE) = 1;
  TOSHOW = CB;
  if 1
  TOSHOW(:,:,1) = TOSHOW_R;
  TOSHOW(:,:,2) = TOSHOW_G;
  TOSHOW(:,:,3) = TOSHOW_B;
  else
  TOSHOW(:,:,1) = inside_weight + outside_weight;
  TOSHOW(:,:,2) = 0;
  TOSHOW(:,:,3) = 0;
  end
  imshow(TOSHOW);
  %Correctly label pixel positions
  set(gca,'XTick',1:(CB_radius*2+1));
  set(gca,'XTickLabel',(-CB_radius:CB_radius) + kp_fix(1));
  set(gca,'YTick',1:(CB_radius*2+1));
  set(gca,'YTickLabel',(-CB_radius:CB_radius) + kp_fix(2));


  hold on
  %Plot pixel centers
  if max_radius < 10
    plot(X(:),Y(:),'y+')
  end
  %Plot the keypoint location  
  plot(kp_debug(1),kp_debug(2),'rx')
  %Plot the radius of the query
  if radius > 0
   % rectangle('Position',[kp_debug(1)-radius,kp_debug(2)-radius,radius*2,radius*2],'EdgeColor','g','Curvature', [1,1],'LineWidth',1);
  end

  inside_weight 
  outside_weight 

  pause
end

