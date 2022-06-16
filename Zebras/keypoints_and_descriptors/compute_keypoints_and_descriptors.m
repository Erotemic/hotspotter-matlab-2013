function [k,d] = compute_keypoints_and_descriptors(I,varargin)
global config

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

if strcmp(config.keypoint_detector,'harris')
  [k,d] = harris_scale(I,varargin);
elseif strcmp(config.keypoint_algorithm,'sift')
  [k,d] = vl_sift(I);
else
    error('Keypoint Algorithgm Unknown')
end
