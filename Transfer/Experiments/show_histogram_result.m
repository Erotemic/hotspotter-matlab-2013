

if strcmp(options.keypoint_algorithm,'sift')
  current_figure = 5555;
elseif strcmp(options.keypoint_algorithm,'harris')
  current_figure = 4444;
end

to_load = 'num_matches'
load([dataset '_experiments/hist_experiment_' options.keypoint_algorithm '_' options.matching_algorithm '_' to_load '.mat'],'hist_experiment');

hist_same = hist_experiment.hist_same;
hist_diff = hist_experiment.hist_diff;
fp_scores = hist_experiment.fp_scores;
fn_scores = hist_experiment.fn_scores;
tp_scores = hist_experiment.tp_scores;
tn_scores = hist_experiment.tn_scores;
ConfusionMatrix = hist_experiment.ConfusionMatrix;
thresh = hist_experiment.thresh;
hist_experiment_name = hist_experiment.hist_experiment_name;
hist_experiment_var = hist_experiment.hist_experiment_var;


figure(current_figure); current_figure = current_figure + 1;
hist(hist_same(hist_same ~= -1 & hist_same < 250),100);
xlabel('Score')
ylabel('Frequency')
title([options.keypoint_algorithm ' ' 'Same Zebras'])
figure(current_figure); current_figure = current_figure + 1;
hist(hist_diff(hist_diff ~= -1),100);
xlabel('Score')
ylabel('Frequency')
title([options.keypoint_algorithm ' ' 'Different Zebras'])

should_match_scores = [tp_scores; fn_scores];
shouldnt_match_scores = [tn_scores; fp_scores];

shouldnt_match_scores(((shouldnt_match_scores(:,1) == 30 | shouldnt_match_scores(:,2) == 30) & (shouldnt_match_scores(:,1) == 81 | shouldnt_match_scores(:,2) == 81)),:)

%Remove duplicates because we are bidirectional and sort by score
should_match_scores = sortrows(unique([sort(should_match_scores(:,1:2),2) should_match_scores(:,3)],'rows'),3);
shouldnt_match_scores = flipud(sortrows(unique([sort(shouldnt_match_scores(:,1:2),2) shouldnt_match_scores(:,3)],'rows'),3));

disp('Worst same matches')
should_match_scores(1:10,:)
disp('Worst diff matches')
shouldnt_match_scores(1:10,:)

%Probability of image being correct
pCorrect = size(should_match_scores,2)/(size(should_match_scores,1)+size(shouldnt_match_scores,2));
%Probability of score given same zebra
pScoreGiveSame = create_pdf(should_match_scores(:,3),'PercentOfTotal',1,'WiggleRoom',.05);
%Probability of score given diff zebra
pScoreGiveDiff = create_pdf(shouldnt_match_scores(:,3),'PercentOfTotal',1,'WiggleRoom',0);
%Probability of a score in general 
%pScore = create_pdf([shouldnt_match_scores(:,3); should_match_scores(:,3)],'PercentOfTotal',1);
%Probability of getting this number
%pScore = pScoreGiveSame + pScoreGiveDiff;
pScore = (pScoreGiveSame*pCorrect + pScoreGiveDiff*(1-pCorrect));
pSameGiveScore = (pScoreGiveSame .* pCorrect)./ pScore;
pDiffGiveScore = (pScoreGiveDiff .* (1-pCorrect))./ pScore;

figure(current_figure); current_figure = current_figure + 1;
hold on
plot(pSameGiveScore(1:200),'r')
plot(pDiffGiveScore(1:200),'b')

legend('P(Same)','P(Diff)')
xlabel('Score')
ylabel('Probability')
title([options.keypoint_algorithm ' ' 'Probability Given Score']);

figure(current_figure); current_figure = current_figure + 1;
hold on
plot(pScoreGiveDiff(1:200),'b')
plot(pScoreGiveSame(1:200),'r')
title([options.keypoint_algorithm ' ' 'Probability of a Score'])
legend({'Different Zebras', 'Same Zebras'})

%figure(current_figure); current_figure = current_figure + 1;
%plot(pScore,'g')
%title({'probability of a score'
%       ['Sum = ' num2str(sum(pScore))]})

%disp(['Probability Correct = ' num2str(pCorrect)])

%Show graph of the cases where the first match isn't correct
%Then show graph of how many inccorect matches are before correct matches. 

%A table of the probability that image i and image j are correct matches
probability_same = -ones(num_ground_truth,num_ground_truth);
%A table of the probability that image i and image j are incorrect matches
probability_diff = -ones(num_ground_truth,num_ground_truth);

missed_indexes = [];
top_probability_score = [];

%An array of correct postions in the probability table. This is used as a 
%primary method of evalutation. Anything where the correct matches are not 
%in the first few positions of the probability list
entry_positions = cell(num_ground_truth,1);

for gti = 1:num_ground_truth

  %For this image, calculate the probabilities it matches with every other image
  for gtj = 1:num_ground_truth
    if gti == gtj
      continue
    end
    %Populate the probability_same/diff matrixes
    if ground_truth(gti,field_data.name_index) == ground_truth(gtj,field_data.name_index)
      if hist_same(gti,gtj)+1 > size(pSameGiveScore,1)
        %TODO This should go back to -2 because these are the same images. These need to be fixed
        probability_same(gti,gtj) = pSameGiveScore(end);
        continue
      end
      probability_same(gti,gtj) = pSameGiveScore(max(0,hist_same(gti,gtj))+1);
      probability_diff(gti,gtj) = pDiffGiveScore(max(0,hist_same(gti,gtj))+1);
    else
      if hist_same(gti,gtj)+1 > size(pSameGiveScore,1)
        probability_same(gti,gtj) = -3;
        continue
      end
      probability_same(gti,gtj) = pSameGiveScore(max(0,hist_diff(gti,gtj))+1);
      probability_diff(gti,gtj) = pDiffGiveScore(max(0,hist_diff(gti,gtj))+1);
    end
  end

  %Find statistics about the probabilities
  actual_matches = ground_truth(ground_truth(:,field_data.name_index) == ground_truth(gti,field_data.name_index),field_data.gt_index);  %Get the indexes of the images that should match
  actual_matches = actual_matches(actual_matches ~= gti)'; %Remove this image from the list 
  [sorted_best_probabilities, sorted_best_matches] = sort(probability_same(gti,:),2,'descend'); %Get a rank order list of probable matches
  
  %Get the positions of the true matches and store them in entry_positions
  match_indexes = zeros(size(actual_matches));
  for match_i = 1:size(actual_matches,2)
    match_indexes(match_i) = find(sorted_best_matches == actual_matches(match_i));
  end
  entry_positions{gti} = match_indexes;

  %Another test is if the correct matches are within the top 2*num_images_that_should_match images
  canidate_matches = sorted_best_matches(1:max(2,size(actual_matches,2))*2);
  hit_matches = intersect(canidate_matches, actual_matches);
  if size(hit_matches,2) ~= size(actual_matches,2)
    missed_matches = setdiff(actual_matches, canidate_matches);
    missed_indexes = [missed_indexes; repmat(gti ,size(missed_matches,2),1) missed_matches'];
  end
end




%for ind = 1:5
%options.figure = (ind+5)*4;
%j = sorted_probability_indexes(77,ind);
%score_zebras(77,j,options)
%figure(ind)
%imshow(get_zebra(j))
%title(['Zebra Index ' num2str(j)])
%pause
%end


[sorted_probability sorted_probability_indexes] = sort(probability_same,2,'descend');




%List of 1's if the top images are correct and 0's if the top images are incorrect
top_images_correct = ground_truth(ground_truth(1:num_ground_truth,field_data.name_index)) == ground_truth(ground_truth(sorted_probability_indexes(:,1),field_data.name_index));
%Find the min, max, ave, stddev of top scoring probability scores that are correct
correct_top_probability = sorted_probability(top_images_correct,1);
min_prob = min(correct_top_probability);
max_prob = max(correct_top_probability);
mean_prob = mean(correct_top_probability);
clear var; %God, I used this as a variable name. Duh
stddev_prob = sqrt(var(correct_top_probability));
disp(['Top Correct Probability Statisitics: '])
disp(['  Min: ' num2str(min_prob) ])
disp(['  Max: ' num2str(min_prob) ])
disp(['  Mean: ' num2str(min_prob) ])
disp(['  StdDev: ' num2str(min_prob) ])

%This table shows all of the i indexes where the top probabilty was not a correct match
%It then tells you what it thought the highest match was the img index/id of that match
%and the probability of that match
inccorect_top_probability = sorted_probability(~top_images_correct,1);
inccorect_top_probability_ids = sorted_probability_indexes(~top_images_correct,1);

i_incorrect_top_index = ground_truth(~top_images_correct,field_data.gt_index);
i_incorrect_top_id = ground_truth(~top_images_correct,field_data.image_id);

j_incorrect_top_index = ground_truth(inccorect_top_probability_ids,field_data.gt_index);
j_incorrect_top_id = ground_truth(inccorect_top_probability_ids,field_data.image_id);

disp(['Incorrect Top Probabilities'])
disp('[imgindex_i imgindex_j probability]:')
disp([i_incorrect_top_index j_incorrect_top_index inccorect_top_probability])

disp(['Incorrect Top Probabilities'])
disp('[imgid_i imgid_j probability]:')
disp([i_incorrect_top_id j_incorrect_top_id inccorect_top_probability])



%Generate a sorted image to show how confident we are in our sorted list
probability_image = flipud(max(0,sorted_probability)');

%Generate a ideal probability image if we got everything right
ground_truth_probability_image = zeros(num_ground_truth,num_ground_truth);
for i = 1:num_ground_truth
  for j = 1:num_ground_truth
    ground_truth_probability_image(i,j) = i ~= j & ground_truth(ground_truth(i,field_data.name_index)) == ground_truth(ground_truth(j,field_data.name_index));
  end
end

%Sort the ground truth the same way as the probability list for comparison 
for i = 1:num_ground_truth
  ground_truth_probability_image(i,:) = ground_truth_probability_image(i,sorted_probability_indexes(i,:));
end
ground_truth_probability_image = flipud(ground_truth_probability_image');

figure(current_figure); current_figure = current_figure + 1;
confidence_tick_resolution = 20;
%Show our confidence, what our confidence should be, and then the difference
subplot(1,3,1);
imshow(probability_image)
set(gca,'ytick',(0:confidence_tick_resolution:num_ground_truth))
set(gca,'yticklabel',fliplr(0:confidence_tick_resolution:num_ground_truth)+confidence_tick_resolution)
title([options.keypoint_algorithm ' ' 'Confidence In Results']);
ylabel('Position in Probability Ranked List')

subplot(1,3,2);
imshow(ground_truth_probability_image);
set(gca,'ytick',(0:confidence_tick_resolution:num_ground_truth))
set(gca,'yticklabel',fliplr(0:confidence_tick_resolution:num_ground_truth)+confidence_tick_resolution)
title([options.keypoint_algorithm ' ' 'Ground Truth Confidence']);
xlabel('Image Index')

subplot(1,3,3);
imshow(abs(ground_truth_probability_image-probability_image));
set(gca,'ytick',(0:confidence_tick_resolution:num_ground_truth))
set(gca,'yticklabel',fliplr(0:confidence_tick_resolution:num_ground_truth)+confidence_tick_resolution)
title([options.keypoint_algorithm ' ' 'Confidence Error']);


ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');

text(0.5, .8,'Sorted Confidence Two Matches Are Correct','HorizontalAlignment', 'center','VerticalAlignment', 'top')








%Plot a graph where the x axis is each individual image and it is given X stems where X is it's number of matches
%each stem is given a height of the position that match is in the probability list. You want them all to be low, 
%because true matches should have the highest probability of matching

max_to_plot = 200;
num_pieces = ceil(num_ground_truth/max_to_plot);

for piece_num = 1:num_pieces
  to_plot_min = 1+(piece_num-1)*max_to_plot;
  to_plot_max = min(num_ground_truth,(piece_num)*max_to_plot);
  figure(current_figure); current_figure = current_figure + 1;
  hold off;
  clf;
  hold on;
  for gti = to_plot_min:to_plot_max
    match_indexes = entry_positions{gti};
    for index = fliplr(1:size(match_indexes,2))
      stem(gti,match_indexes(index), 'o' ,'Color','k','MarkerSize',2,'MarkerFaceColor','r','MarkerEdgeColor','k');
    end
  end
  set(gca,'XTick',to_plot_min:4:to_plot_max)
  set(gca,'TickLength',[0 0])
  xlabel('image index')
  ylabel('sorted probability rank')
  title({[options.keypoint_algorithm ' ' 'Number of entries before a correct match']
         'The circles each represent a ground truth match'})
end


%Display the test results for the second criteria
actual_missed = unique(sort(missed_indexes,2),'rows')
disp(['We missed ' int2str(size(actual_missed,1)) ' matches']);



