addpath('DownloadedLibraries/addpath_recurse')
addpath_recurse('DownloadedLibraries')
addpath_recurse('.')

initialize_system;

%Load prexisting configuration
if exist('saved_configuration.mat','file') 
  load('saved_configuration.mat')
  disp('Previous Configuration Loaded');
end

set_sample_set(config.sample_set);
set_data_directory(config.data_directory);
