function [norm_list, list_lengths] = normalize_vector_list(list)

list_lengths = vector_list_norm2(list);
norm_list = list./repmat(list_lengths,[2 1]);

