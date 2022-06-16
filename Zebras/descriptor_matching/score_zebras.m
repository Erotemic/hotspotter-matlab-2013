function [score,results] = score_zebras(i,j,varargin)

%The score is the number of spatially consistent matches
matches = get_computed_match(i,j,varargin);
nmatches = size(matches,2);
results.nmatches = nmatches;
score = nmatches;

%global ground_truth
%global field_data
%
%experiment_score = 0;
%results.num_inliers1 = 4;
%results.num_inliers2 = 4;
%options = [];
%if size(varargin,1) > 0
%  options = varargin{1};
%end
%if i == j
%  score = -2;
%  return
%end 
%
%img1 = get_zebra(i);
%img2 = get_zebra(j);
%
%ransac_dist_thresh = min(size(img2,1),size(img1,2))*.1;
%
%f1 = query_property(i,-1,'keypoints');
%d1 = query_property(i,-1,'descriptors');
%f2 = query_property(j,-1,'keypoints');
%d2 = query_property(j,-1,'descriptors');
%
%[matches scores] = get_computed_match(i,j);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% X1 and X2 are coordinates with 
%%  matching indexes means a match
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if(size(matches,2) == 0)
%    score = 4;
%    %set_property(score,i,j,'similarity','bidirectional');
%    return 
%end
%nmatches = size(matches,2);
%%If there are less than 10 matches don't even bother 
%%doing any computations
%if nmatches < 10
%  %TODO make the program not bother
%  score = 4;
%  %set_property(score,i,j,'similarity','bidirectional');
%  return
%end 
%
%%Quick hack to save homographies, should work into 
%%actual code later
%persistent precomputed_homogs
%global num_ground_truth
%if isempty(precomputed_homogs) 
%  precomputed_homogs = cell(num_ground_truth,num_ground_truth,3);
%end
%
%if isempty(precomputed_homogs{i,j}) | 1
%  sel_f1 = f1(:, matches(1,:));
%  sel_f2 = f2(:, matches(2,:));
%  %Grab a homogrphy matrix from img1 space to img2 space
%  [H1, best_inliers1, tsel_f1] = ransac_homography(sel_f1,...
%                                                   sel_f2,...
%                                                  'DistThresh',ransac_dist_thresh,...
%                                                  'FilterOrientation',1);
%  [H2, best_inliers2, tsel_f2] = ransac_homography(sel_f2,...
%                                                   sel_f1,...
%                                                  'DistThresh',ransac_dist_thresh,...
%                                                  'FilterOrientation',1);
%  precomputed_homogs{i,j,1} = H1;
%  precomputed_homogs{i,j,2} = best_inliers1;
%  precomputed_homogs{i,j,3} = tsel_f1;
%
%  precomputed_homogs{j,i,1} = H2;
%  precomputed_homogs{j,i,2} = best_inliers2;
%  precomputed_homogs{j,i,3} = tsel_f1;
%else
%  H1 = precomputed_homogs{i,j,1};
%  best_inliers1 = precomputed_homogs{i,j,2};
%  tsel_f2 = precomputed_homogs{i,j,3};
%  H2 = precomputed_homogs{j,i,1};
%  best_inliers2 = precomputed_homogs{j,i,2};
%  tsel_f3 = precomputed_homogs{j,i,3};
%end
%
%num_inliers1 = size(best_inliers1,2);
%num_inliers2 = size(best_inliers2,2);
%
%%percent_in = num_inliers*100 / nmatches;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Show Results
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Change x1 coordinates to x2 coordinate
%
%results.H1 = H1;
%results.H2 = H2;
%results.num_inliers1 = num_inliers1;
%results.num_inliers2 = num_inliers2;
%
%experiment_score = num_inliers1 + num_inliers2;
%
%score = experiment_score;
%
%if score ~= score
%  score = 99999;
%end
%%set_property(score,i,j,'similarity','bidirectional');
%
%
%%Lastly show a visualization if requested
%if 1 | strcmp(class(options),'struct') & options.displayon == 1 
%
%  %Set up figure information
%  persistent experiment_figure
%  if isempty(experiment_figure)
%    experiment_figure = 1;
%  end
%  %Set the figure number to use defined figure
%  if isfield(options,'figure')
%    if experiment_figure ~= options.figure
%      experiment_figure = options.figure;
%    end
%  end
%
%  %Draw the first homography
%  figure(experiment_figure+1);
%
%  [img1T, imgBoth] = merge_images(H1,img1,img2);
%  [r1 c1 tmpdim] = size(img1T);
%  [r2 c2 tmpdim] = size(imgBoth);
%  row = r1+r2;
%  col = max(c1,c2);
%
%  imgtoshow = uint8(zeros(row,col,tmpdim));
%  imgtoshow(1:r1,1:c1,:) = img1T;
%  imgtoshow(r1+1:row,1:c2,:) = imgBoth;
%
%  clf
%  imshow(imgtoshow);
%
%  hold on
%
%  for matchi = 1:size(sel_f2,2)
%    lineh = line([tsel_f1(1,matchi)' sel_f2(1,matchi)'], [tsel_f1(2,matchi)' sel_f2(2,matchi)'],'LineWidth',2);
%  end
%
%  %Plot img2 points on the transformed image and itself
%  nmatches
%  size(sel_f2)
%  f2h = vl_plotframe(sel_f2);
%  set(f2h,'color','r','linewidth',1); 
%  tmph = vl_plotframe(sel_f2 + [zeros(1,nmatches); zeros(1,nmatches)+r1; zeros(1,nmatches); zeros(1,nmatches)]);
%  set(tmph,'color',[.9,.1,.1],'linewidth',2)
%  tf1h = vl_plotframe(tsel_f1);
%  set(tf1h,'color','g','linewidth',1);
%
%  %plot(tsel_f1(1,:), tsel_f1(2,:),'ro','MarkerSize',10,'LineWidth',4);  
%  %plot(sel_f2(1,:), sel_f2(2,:),'go','MarkerSize',5,'LineWidth',3);
%  inlierh = plot(tsel_f1(1,best_inliers1), tsel_f1(2,best_inliers1),'*','MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1);
%  
%
%
%  title_and_features1 = {...
%  'img1 projected onto to img2'
%  ['score = ' num2str(score)]
%  ['num inliers1 = ' num2str(num_inliers1) ' num inliers1 = ' num2str(num_inliers2)]
%  };
%  title(title_and_features1)
%  legend([lineh, f2h, tf1h inlierh], 'matching points','img2points', 'transformed img1point', 'inliers')
%  
%  hold off
%
%  %Draw the second homography  
%  figure(experiment_figure+2);
%
%  [img2T, imgBoth] = merge_images(H2,img2,img1);
%  [r1 c1 tmpdim] = size(img2T);
%  [r2 c2 tmpdim] = size(imgBoth);
%  row = r1+r2;
%  col = max(c1,c2);
%
%  imgtoshow = uint8(zeros(row,col,tmpdim));
%  imgtoshow(1:r1,1:c1,:) = img2T;
%  imgtoshow(r1+1:row,1:c2,:) = imgBoth;
%
%  clf
%  imshow(imgtoshow);
%
%  hold on
%
%  for matchi = 1:size(sel_f2,2)
%    lineh = line([tsel_f2(1,matchi)' sel_f1(1,matchi)'], [tsel_f2(2,matchi)' sel_f1(2,matchi)'],'LineWidth',2);
%  end
%
%  f1h = vl_plotframe(sel_f1);
%  set(f1h,'color','r','linewidth',1);  
%  tmph = vl_plotframe(sel_f1 + [zeros(1,nmatches); zeros(1,nmatches)+r1; zeros(1,nmatches); zeros(1,nmatches)]);
%  set(tmph,'color',[.9,.1,.1],'linewidth',2)
%  tf2h = vl_plotframe(tsel_f2);
%  set(tf2h,'color','g','linewidth',1);
%
%  %plot(tsel_f2(1,:), tsel_f2(2,:),'ro','MarkerSize',10,'LineWidth',4);  
%  %plot(sel_f1(1,:), sel_f1(2,:),'go','MarkerSize',5,'LineWidth',3);
%  inlierh = plot(tsel_f2(1,best_inliers2), tsel_f2(2,best_inliers2),'*','MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1);
%  
%  
%
%  title_and_features2 = {...
%  'img2 projected onto to img1'
%  ['score = ' num2str(score)]  
%  ['num inliers2 = ' num2str(num_inliers2) ' num inliers1 = ' num2str(num_inliers1)]
%  };
%  title(title_and_features2)
%  %legend('Location','BestOutside','img1 points','img2points','match dist', 'inliers')
%  legend([lineh, f1h, tf2h inlierh], 'matching points','img1points', 'transformed img2point', 'inliers')
%
%  best_inliers = union(best_inliers1,best_inliers2);
%
%  figure(experiment_figure+3);
%  Image1 = img1;
%  Image2 = img2;
%  [r1 c1 tmpdim] = size(Image1);
%  [r2 c2 tmpdim] = size(Image2);
%  row = r1+r2;
%  col = max(c1,c2);
%     
%  BothImages = uint8(zeros(row,col,tmpdim));
%  BothImages(1:r1,1:c1,:) = Image1;
%  BothImages(r1+1:row,1:c2,:) = Image2;
%
%  imshow(BothImages);
%  sel_f2_trans = sel_f2 + repmat([0;r1;0;0],[1,size(sel_f2,2)]);
%
%  selected_f1 = sel_f1(:,best_inliers);
%  selected_f2 = sel_f2_trans(:,best_inliers);
%
%  h1 = vl_plotframe(selected_f1) ; 
%  h2 = vl_plotframe(selected_f2) ; 
%  set(h1,'color','y','linewidth',3) ;
%  set(h2,'color','y','linewidth',2) ;
%
%
%  for match = best_inliers
%     xposes = [sel_f1(1,match), sel_f2_trans(1,match)];
%     yposes = [sel_f1(2,match), sel_f2_trans(2,match)];
%     l1 = line(xposes,yposes,'LineWidth',3);
%  end
%
%  imgid1 = int2str(ground_truth(i,field_data.image_id));
%  imgid2 = int2str(ground_truth(j,field_data.image_id));
%  title_str1 = ['(imgid ' imgid1 ') vs (imgid ' imgid2 ')'];
%  title_str2 = ['(img index ' int2str(i) ') vs (img index ' int2str(j) ')'];
%  title({'Spatially Verified Matches',title_str1,title_str2})
%   
%
%  hold off
%end
%
%
