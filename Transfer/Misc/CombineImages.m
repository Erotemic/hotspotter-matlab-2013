function [BothImages, shift_y] = CombineImages(Image1, Image2)
[r1 c1 tmpdim] = size(Image1);
[r2 c2 tmpdim] = size(Image2);
row = r1+r2;
col = max(c1,c2);
 
BothImages = uint8(zeros(row,col,tmpdim));
BothImages(1:r1,1:c1,:) = Image1;
BothImages(r1+1:row,1:c2,:) = Image2;

shift_y = r1;
