%Normalizes a matrix to the range 0 to 1
%If the Image flag is specified then each channel is 
%normalized by itself
function [output] = norm_zero_one(input,varargin)
  %%%%%%%%%%%%%%%%%%%%%%%%
  %The setup is in this block
  %%%%%%%%%%%%%%%%%%%%%%%% 
  if size(varargin,2) > 0
    isImage = 0;
    for i = 1:size(varargin,2)
      if strcmp(varargin{i},'Image')
        isImage = 1;
      end
    end
    if isImage
      for channel = 1:size(input,3)
        output(:,:,channel) = norm_zero_one(input(:,:,channel));
      end
    end
  %%%%%%%%%%%%%%%%%%%%%%%%
  %The logic is in this block
  %%%%%%%%%%%%%%%%%%%%%%%% 
  else
    min_val = min(input);
    max_val = max(input);

    %Get the minimium value over all dimensions
    while size(size(min_val),2) ~= 2 || sum(size(min_val) == [1 1]) ~= 2
      min_val = min(min_val);
      max_val = max(max_val);
    end

    max_range = max_val - min_val;
    output = double((double(input) - double(min_val)) ./ double(max_range));
  end
end
