%=====================================================================
% If you apply a colormap, MATLAB has a "feature" where it applies the
% colormap to ALL the axes on the figure, not just the current axes.  So if
% you apply a colormap to the current axes (your pie chart) thinking it
% will affect only your pie chart, you will be surprised to find it affects
% all other charts and images on the dialog box.  To get around that, use
% this function which the colors of the pie segments and does not affect
% any other objects in the dialog box.  You need to pass in
% hPieComponentHandles which you get when you create the pie chart:
%	hPieComponentHandles = pie([Value1, Value2, Value3],{'Label 1','Label 2','Label 3'});
% Then make up your color map like this:
% 	pieColorMap(1,:) = [.22 .71 .29];	% Color for segment 1.
% 	pieColorMap(2,:) = [.25 .55 .79];	% Color for segment 2.
% 	pieColorMap(3,:) = [.93 .11 .14];	% Color for segment 3.
% and finally, call this function
%	SetPieChartColors(hPieComponentHandles, pieColorMap);
function SetPieChartColors(hPieComponentHandles, PieSegmentColors)
	set(hPieComponentHandles(1),'FaceColor', PieSegmentColors(1,:));
	set(hPieComponentHandles(3),'FaceColor', PieSegmentColors(2,:));
	set(hPieComponentHandles(5),'FaceColor', PieSegmentColors(3,:));
	return;
	