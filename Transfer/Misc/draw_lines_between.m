function [] = draw_lines_between(Pos1, Pos2,Color)

if sum(size(Pos1) ~= size(Pos2))
  error('Pos1 and Pos2 must be same size')
end

for index = 1:size(Pos1,2)
  if norm(Pos1(:,index)-Pos2(:,index)) > 50
    %continue
  end
  if ~exist('Color','var')
  line([Pos1(1,index) Pos2(1,index)],...
       [Pos1(2,index) Pos2(2,index)],...
       'LineWidth', 3);
  else
  line([Pos1(1,index) Pos2(1,index)],...
       [Pos1(2,index) Pos2(2,index)],...
       'LineWidth', 3,'Color',Color);
  end
end
