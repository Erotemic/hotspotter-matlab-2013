% get_image
%
% Gets an image from the get_file function
% Cuts off the top 8 pixels to remove metadata
function [Image] = get_zebra(i, varargin)
global config

i_index = config.sample_set(i);

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

ImageFull = imread(config.image_filenames{i_index});

[rsize csize dim] = size(ImageFull);
maxr = max(rsize, 400)/rsize;
maxc = max(csize, 400)/csize;

Image = imresize(ImageFull,max(maxr,maxc),'lanczos2');

