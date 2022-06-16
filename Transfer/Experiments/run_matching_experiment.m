% run_sift_experiment(i,j,options)
% 
% i: first image to compare
% j: second image to compare
% 
% options: structure with following optional fields
% options.displayon
% options.figurenum
% options.showkeypoints
% options.showdescriptors
% options.showallkeypoints
function [] = run_matching_experiment(i,j,varargin)
global matching_experiment_options;
global figure_names;
global radius_per_scale;
global config;

%If preferences haven't been set. 
if isempty(matching_experiment_options)
  matching_experiment_options.show_matches = 1;
  matching_experiment_options.show_raw_matches = 0;
  matching_experiment_options.show_all_keypoints = 0;
  matching_experiment_options.show_keypoints = 1;
  matching_experiment_options.show_descriptors = 1;
end

if i == j
  return
end

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

for index = 1:length(varargin)
  arg = varargin{index};
end

figure(figure_names.matching_experiment);

Image1 = get_zebra(i);
Image2 = get_zebra(j);

[r1 c1 tmpdim] = size(Image1);
[r2 c2 tmpdim] = size(Image2);
row = r1+r2;
col = max(c1,c2);
 
BothImages = uint8(zeros(row,col,tmpdim));
BothImages(1:r1,1:c1,:) = Image1;
BothImages(r1+1:row,1:c2,:) = Image2;

imshow(BothImages);


imgid1 = config.sample_set(i);
imgid2 = config.sample_set(j);

title_str1 = ['Matching Experiment (imgid ' num2str(imgid1) ') vs (imgid ' num2str(imgid2) ')'];
title_str2 = ['(img index ' num2str(i) ') vs (img index ' num2str(j) ')'];

title({title_str1,title_str2})

%Populate selected_matches with the matches you want to display
if matching_experiment_options.show_raw_matches == 0
 [selected_matches, selected_scores] = get_computed_match(i,j,varargin);
else
 [~, ~, selected_matches, selected_scores] = get_computed_match(i,j,varargin);
end

%Don't pass down varargin here because it should have 
%already done anything fancy in get_computed_match
f1 = query_property(i,-1,'keypoints');
d1 = query_property(i,-1,'descriptors');


f2 = query_property(j,-1,'keypoints');
f2_shifted = f2 + repmat([0;r1;0;0],[1,size(f2,2)]);   
d2 = query_property(j,-1,'descriptors');



selected_f1 = [];
selected_f2 = [];
%If on only keypoints and descriptors of matches are drawn
if matching_experiment_options.show_all_keypoints == 1
 selected_d1 = d1;
 selected_d2 = d2;
 selected_f1 = f1;
 selected_f2 = f2_shifted;
else
 if ~isempty(selected_matches)
   selected_d1 = d1(:,selected_matches(1,:));
   selected_d2 = d2(:,selected_matches(2,:));
   selected_f1 = f1(:,selected_matches(1,:));
   selected_f2 = f2_shifted(:,selected_matches(2,:));
 end
end


%Plot the SIFT keypoints if requested
if (~isempty(selected_f1) && matching_experiment_options.show_keypoints == 1)
 h1 = vl_plotframe(selected_f1) ; 
 h2 = vl_plotframe(selected_f2) ; 
 set(h1,'color','y','linewidth',.5) ;
 set(h2,'color','y','linewidth',.5) ;
end

%Plot the SIFT descriptors if requested
if matching_experiment_options.show_descriptors == 1
 if 1
 %Use circles instead of vldescriptors
   for kp = [selected_f1 selected_f2]
     radius = kp(3)*radius_per_scale;     
     rectangle('Position',[kp(1)-radius,kp(2)-radius,radius*2,radius*2],'Curvature', [1,1],'EdgeColor','g') ;
   end
 else
 %Plot vl descriptors 
   h3 = vl_plotsiftdescriptor(selected_d1, selected_f1) ; 
   h4 = vl_plotsiftdescriptor(selected_d2, selected_f2) ; 
   set(h3,'color','g') ;
   set(h4,'color','g') ;
 end
end 



if (~isempty(selected_scores) && matching_experiment_options.show_matches == 1)
 cmap = colormap('Winter'); 
 

 norm_scores = int32(norm_zero_one(selected_scores)*(size(cmap,1)-1))+1;
 
 for match_index = 1:size(selected_matches,2)

   
   match = selected_matches(:,match_index);
   score = norm_scores(match_index);
   xposes = [f1(1,match(1)), f2_shifted(1,match(2))];
   yposes = [f1(2,match(1)), f2_shifted(2,match(2))];
   l1 = line(xposes,yposes,'LineWidth',3);
   
   set(l1,'color',cmap(score,:),'LineWidth',2 * (1.001-(double(score)/double(size(cmap,1)))) );
 end

  %colorbar('YTickLabel',linspace(min(selected_scores),max(selected_scores),7));
  
end

%end function
