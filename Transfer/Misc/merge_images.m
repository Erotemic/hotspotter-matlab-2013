function [img1T, imgBoth] = merge_images(H, img1, img2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Merge the two images using the Homography
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Create a canvas for both images
%img3 = uint8(zeros(maxh-miny, maxw - minx, 3));
%minx

[~,~,dim] = size(img1);

imgBoth = uint8(img2);
img1T = uint8(zeros(size(img2)));

img2_xy = allcomb(1:size(img2,2), 1:size(img2,1));
img2_xyw = [img2_xy(:,1) img2_xy(:,2) ones(size(img2_xy,1),1)]';
trans_points_scaled = inv(H)*img2_xyw;
img1_Hx = trans_points_scaled(1,:);
img1_Hy = trans_points_scaled(2,:); 
img1_Hw = trans_points_scaled(3,:);
tpoints = int32([img1_Hx ./ img1_Hw; img1_Hy ./ img1_Hw]);

in_indexes = tpoints(1,:) > 1 & tpoints(2,:) > 1 & tpoints(1,:) < size(img1,2) & tpoints(2,:) < size(img1,1);

for pti = 1:size(img2_xy,1)
  if in_indexes(pti)
    img1T(img2_xy(pti,2),img2_xy(pti,1),1) = img1(tpoints(2,pti),tpoints(1,pti),1);
    if dim == 3
      img1T(img2_xy(pti,2),img2_xy(pti,1),2) = img1(tpoints(2,pti),tpoints(1,pti),2);
      img1T(img2_xy(pti,2),img2_xy(pti,1),3) = img1(tpoints(2,pti),tpoints(1,pti),3);
    end
  end
end

imgBoth = (imgBoth + img1T./3)./2;
