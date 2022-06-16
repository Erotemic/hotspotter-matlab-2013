function [] = plotframe(f,color)

  if ~exist('color','var')
    color = [1 0 0];
  end

  if size(f,1) == 4
  tmp_u = f(3,:).*cos(f(4,:));
  tmp_v = f(3,:).*sin(f(4,:));

  quiver(f(1,:),...
         f(2,:),...
         tmp_u,...
         tmp_v,...
         'Color', color);

  vl_plotframe(f,'LineWidth',1,'Color',color);       
  end

  plot(f(1,:),f(2,:),'x','Color',color);         


  %if size(f,1) == 4
  %  for kp = f
  %    scale = kp(3);
  %    theta = kp(4);
  %    tmp_u = (scale) * cos(theta) ;
  %    tmp_v = (scale) * sin(theta) ;
  %    h = quiver(kp(1),kp(2),tmp_u,tmp_v);
  %  end
  %end
