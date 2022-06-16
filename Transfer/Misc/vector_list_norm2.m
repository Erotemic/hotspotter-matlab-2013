function [norm_list, lengths] = vector_list_norm2(list)

norm_list = zeros(1,size(list,2));
for list_i = 1:size(list,2)
  norm_list(list_i) = norm(list(:,list_i),2);
end

