%This algorithm is a ratio test followed by checking to make sure
%that if pt1 matches to pt2, pt2 also matches to pt1
function [matches, scores] = get_match_bidirectional(kp1, kp2, desc1, desc2 ,varargin)

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

[matches_dir1, scores_dir1] = vl_ubcmatch(desc1,desc2); 
[matches_dir2, scores_dir2] = vl_ubcmatch(desc2,desc1); 
num_matches_default1 = size(matches_dir1,2);
num_matches_default2 = size(matches_dir2,2);

initial_size = size(matches_dir1,2);
bidirectional_matches = -ones(2,initial_size);
bidirectional_scores = -ones(1,initial_size);
good_match_index = 1;

for match_index1 = 1:initial_size
  d1_index = matches_dir1(1,match_index1);
  d2_index = matches_dir1(2,match_index1);
  
  match_index2 = find(matches_dir2(1,:) == d2_index & matches_dir2(2,:) == d1_index);
  if size(match_index2,2) == 1
    bidirectional_matches(:,good_match_index) = [d1_index; d2_index];
    bidirectional_scores(1,good_match_index) = max(scores_dir1(match_index1),scores_dir2(match_index2));      
    good_match_index = good_match_index + 1;
  end
end 

num_bidirectional_matches = good_match_index-1;

if num_bidirectional_matches > 0
  matches = bidirectional_matches(:,1:num_bidirectional_matches);
  scores = bidirectional_scores(:,1:num_bidirectional_matches);
else
  matches = [];
  scores = [];
end
