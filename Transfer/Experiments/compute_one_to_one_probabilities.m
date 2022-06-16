global num_ground_truth
global sample_size
global ground_truth
global field_data
global options

%TODO Need to put a ground truth scheme into the property section 
%     Also I need to make an easier way to compute 1 to 1 probabilities
%Run all experiments
if 0
 to_run = {...
  'nmatches'           'nmatches'};

  to_run = {'num_inliers1and2'   'nmatches'};
  ind = 1;

  for ind = 1:size(to_run,1)
    hist_experiment_var  = to_run{ind,2};
    hist_experiment_name = to_run{ind,1};
    generate_histogram_experiment  
  end
end


%Just in case
if ~exist('hist_experiment_var')
  hist_experiment_var = 'nmatches';
  hist_experiment_name = 'num_matches';
end

disp(['Running ' hist_experiment_name])

match_hist = -ones(sample_size,sample_size);

images_to_score = 1:sample_size;

no_print = 0;

for i = images_to_score
  if ~no_print
    tic
    fprintf('i = %.3d\n',i)
    disp('--------')
    disp('^^^^^^^^^')
  end
  for j = images_to_score
    if ~no_print
      fprintf('\b\b\b\b\b\b\b\b\b\b  j = %.3d\n',j)
    end

    if i >= j 
      continue
    end
    [matches scores] = get_computed_match(i,j,'recomputematches');
    %[matches scores] = get_computed_match(i,j);
    nmatches = size(matches,2);
    match_hist(i,j) = nmatches;
  end
  
  if ~no_print
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b')
    toc
  end
end

%Because of the random nature of the algorithm
%scores may not be exactly symetrical. Just force it
hist_diff = max(triu(hist_diff+1)-1, triu(hist_diff+1)'-1)
hist_same = max(triu(hist_same+1)-1, triu(hist_same+1)'-1)


%Annotate scores with rows and columns
[indexr indexc] = find(hist_same~=-1);
same_index_score = [indexr indexc hist_same(hist_same~=-1)];
[indexr indexc] = find(hist_diff~=-1);
diff_index_score = [indexr indexc hist_diff(hist_diff~=-1)];

high_thresh = max(max(same_index_score(:,3)),max(diff_index_score(:,3)));
low_thresh  = min(min(same_index_score(:,3)),min(diff_index_score(:,3)));
mid_thresh = (high_thresh+low_thresh)/2;

%Find the best threshhold that will separate the data
while 1
  mid_high_thresh = (high_thresh+mid_thresh)/2;
  mid_low_thresh = (low_thresh+mid_thresh)/2;
  fn_scores_high = same_index_score(same_index_score(:,3) <= mid_high_thresh,:);
  fp_scores_high = diff_index_score(diff_index_score(:,3) >  mid_high_thresh,:);

  fn_scores_low = same_index_score(same_index_score(:,3) <= mid_low_thresh,:);
  fp_scores_low = diff_index_score(diff_index_score(:,3) >  mid_low_thresh,:);

  low_score = size(fp_scores_low,1) + size(fn_scores_low,1);
  high_score = size(fp_scores_high,1) + size(fn_scores_high,1);

  if low_score <= high_score
    high_thresh = mid_thresh;
    mid_thresh = (high_thresh+low_thresh)/2;
  else
    low_thresh = mid_thresh;
    mid_thresh = (high_thresh+low_thresh)/2;
  end

  if high_thresh - low_thresh < 2
    break
  end
end

thresh = mid_thresh;

tp_scores = same_index_score(same_index_score(:,3) > thresh,:);
fn_scores = same_index_score(same_index_score(:,3) <= thresh,:);
fp_scores = diff_index_score(diff_index_score(:,3) > thresh,:);
tn_scores = diff_index_score(diff_index_score(:,3) <= thresh,:);

tp = size(tp_scores,1);
fp = size(fp_scores,1);
tn = size(tn_scores,1);
fn = size(fn_scores,1);

ConfusionMatrix = [tp fn; fp tn]

hist_experiment.hist_same = hist_same;
hist_experiment.hist_diff = hist_diff;
hist_experiment.fp_scores = fp_scores;
hist_experiment.fn_scores = fn_scores;
hist_experiment.tp_scores = tp_scores;
hist_experiment.tn_scores = tn_scores;
hist_experiment.ConfusionMatrix = ConfusionMatrix;
hist_experiment.thresh = thresh;
hist_experiment.hist_experiment_var = hist_experiment_var;
hist_experiment.hist_experiment_name = hist_experiment_name;

eval([hist_experiment_name '_experiment = hist_experiment;']);

if ~exist([dataset '_experiments'])
  mkdir([dataset '_experiments'])
end

save([dataset '_experiments/hist_experiment_' options.keypoint_algorithm '_' options.matching_algorithm '_' hist_experiment_name '.mat'],'hist_experiment');
