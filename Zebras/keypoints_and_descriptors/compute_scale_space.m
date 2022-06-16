function [ScaleSpace] = compute_scale_space(I,varargin)


%Format the image 
[rsize csize dim] = size(I);
scale_factor = 1;

if rsize <= 400 | csize <= 400
  disp('Warning: Region too small. Resizing');  
  maxr = max(rsize, 400)/rsize;
  maxc = max(csize, 400)/csize;

  scale_to_r = 400 / rsize;
  scale_to_c = 400 / csize;
  scale_factor = max([1,scale_to_r,scale_to_c]);
  I = imresize(I, scale_factor, 'lanczos2');
end
%Make sure the input is a single grayscale image
if dim == 3
  disp('Warning: Input image is not black and white. Converting...');
  I = single(rgb2gray(I));
end


display_on     = 0; %Controls Debug Display
num_scales     = 3; %Controls the number of scales
sigma = .5; %Sigma for scale space

for var_index = 1:size(varargin,2)
  var = varargin{var_index};
  if strcmp(var,'num_scales')
    num_scales = varargin{var_index + 1};
  end
  if strcmp(var,'sigma')
    sigma = varargin{var_index + 1};
  end
end

L = gaussfilt(I,sigma);

%TODO: Create an octavelike sort of representation
%      And find harris corners that are maxima in scalespace
%      as well as spatially 
%Create a pyramid in scale space
ScaleSpaceI     = cell(1,num_scales);
ScaleSpaceGx    = cell(1,num_scales);
ScaleSpaceGy    = cell(1,num_scales);
ScaleSpaceGIMag = cell(1,num_scales);
ScaleSpaceGIori = cell(1,num_scales);

ScaleSpaceI{1} = L;
[Ix, Iy] = derivative5(L, 'x', 'y');
ScaleSpaceGx{1} = Ix;
ScaleSpaceGy{1} = Iy;
ScaleSpaceGIMag{1} = sqrt(Ix.^2 + Iy.^2);
ScaleSpaceGIOri{1} = atan2(double(Iy),double(Ix));

for scale_index = 2:num_scales
  %Because I*G(4s) = downsample(I*G(2s))*G(2s)
  %Convolving a scaled down image with the same kernel
  %will replicate a larger sigma in scale space

  blur = gaussfilt(L,sigma);
  subsample = blur(1:2:end,1:2:end);

  L = subsample;
  ScaleSpaceI{scale_index} = L;
  [Ix, Iy] = derivative5(L, 'x', 'y');
  ScaleSpaceGx{scale_index} = Ix;
  ScaleSpaceGy{scale_index} = Iy;
  ScaleSpaceGIMag{scale_index} = sqrt(Ix.^2 + Iy.^2);
  ScaleSpaceGIOri{scale_index} = atan2(double(Iy),double(Ix));
end

ScaleSpace.num_scales = num_scales;
ScaleSpace.initial_sigma = sigma;
ScaleSpace.I     = ScaleSpaceI;
ScaleSpace.Gx    = ScaleSpaceGx;
ScaleSpace.Gy    = ScaleSpaceGy;
ScaleSpace.GIMag = ScaleSpaceGIMag;
ScaleSpace.GIOri = ScaleSpaceGIOri;
ScaleSpace.scale_factor = scale_factor; %initial resize 
