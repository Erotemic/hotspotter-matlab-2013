function [] = start_sytem(varargin)
global config 

disable_registry = 0;

for var_index = 1:size(varargin,1)
  var = varargin{var_index};
  if strcmp(var,'disable_registry') | strcmp(var,'dr')
    disable_registry = 1;
  end
end

initialize_system;

%Load prexisting configuration
if exist('saved_configuration.mat','file') & ~disable_registry
  load('saved_configuration.mat')
  disp('Previous Configuration Loaded');
end

main_window_handle = MainWindow;

set_sample_set(config.sample_set);
set_data_directory(config.data_directory);
