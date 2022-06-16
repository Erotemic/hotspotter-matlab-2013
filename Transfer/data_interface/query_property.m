%Description: 
%       Gets a property from whatever the current
%       storage method is.
%Usage:
%       query_property(i,j,propname,options)
%
function [property] = query_property(i,j,prop_name,varargin)
global PathName
global num_ground_truth
global StoredData
global computed_fields
global statistic_fields
global config

i_index = config.sample_set(i);
if j == -1
  j_index = -1;
else
  j_index = config.sample_set(j);
end

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

%Different properties may need different arguments, 
%get them here. 
for vari = 1:size(varargin,2)
  var = varargin{vari};
  %There doesn't seem to be anything here ¯\(°_0)/¯
end

%Check to see if the query is a special case like keypoints where 
%it will compute it if unknown
%--------
%These properties are computed together differentiate between them later
if strcmp(prop_name,'keypoints') | strcmp(prop_name,'descriptors')
  %Compute or return computed keypoints    
  computed = load_computed(i_index,varargin);
  if computed.keypoints == -1
    Image = get_zebra(i);
    [computed.keypoints computed.descriptors] = compute_keypoints_and_descriptors(single(rgb2gray(Image)),varargin);
    save_computed(i_index,computed);
  end
  %Differentiate between which property the user wants
  if strcmp(prop_name,'descriptors')
    property = computed.descriptors;
  elseif strcmp(prop_name,'keypoints')
    property = computed.keypoints;
  end
%--------
%largest_keypoint_cluster
%  Requires: i_index
%  Returns: The largest number of keypoints within a radius of each other
%           currently the value is 10. This is used for the ratio test to
%           get an idea of how many nearest neighbors you need to look at 
%           before you are gaurenteed to get a valid match for the ratio test
elseif strcmp(prop_name,'largest_keypoint_cluster')
  computed = load_computed(i_index,varargin);  
  if computed.largest_keypoint_cluster == -1
    k = query_property(i,j,'keypoints');
    kpts = k(1:2,:);
    forest = vl_kdtreebuild(kpts);
    [~, dists] = vl_kdtreequery(forest,kpts,kpts,'NUMNEIGHBORS',size(kpts,2));
    %Right now this property returns the maximum number of 
    %keypoints within a 30 radius of each other. If 30 is not
    %Enough this should be extended to arbitrary radii, but
    %for now use 30 as a magic number
    %Another problem with this line of code is if all keypoints are
    %detected within this radius
    larget_keypoint_cluster_thresh_sqrd_dist = 100;
    [kpts_within_thresh, ~] = find(dists < larget_keypoint_cluster_thresh_sqrd_dist);
    computed.largest_keypoint_cluster = max(kpts_within_thresh);
    save_computed(i_index,computed);
  end
  property = computed.largest_keypoint_cluster;
%--------
%num_matching_imgs
%
%  Requires: i
%  Returns: number of images in the database of the same known zebra
elseif strcmp(prop_name,'num_matching_imgs')
  gt_id = query_property(i,'gt_id')
  if gt_id == -1
    property = -1;
  else
    ground_truth = load_ground_truth(varargin);
    property = size(ground_truth.gtid_to_imgids(gt_id),2);
  end
elseif strcmp(prop_name,'gt_id')
  property = get_gtid_from_name(query_property(i,-1,'name'));
%--------
%If none of the special cases happen just return the 
%structure field value
%
elseif sum(strcmp(prop_name,{computed_fields{1,:}}))
  computed = load_computed(i_index,varargin);
  property = getfield(computed,prop_name);
elseif sum(strcmp(prop_name, statistic_fields))
  statistics = load_statistics(i_index,varargin);
  stat_field = getfield(statistics,prop_name);
  property   = stat_field(j_index);
%--------  
else
    disp(['Warning: No Property ' prop_name])
    property = -1;
    error(['No property: ' prop_name])
end
    
