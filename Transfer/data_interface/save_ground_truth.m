%i_index currently does nothing
function [] = save_ground_truth(ground_truth1)
global ground_truth
global config

ground_truth = ground_truth1;

filename = [config.data_directory 'ground_truth.mat'];  
save(filename,'ground_truth')


