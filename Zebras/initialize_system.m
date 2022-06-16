warning('off','MATLAB:declareGlobalBeforeUse')
global figure_names; %Makes sure figures don't overlap with each other
global config; %Configuration Parameters. 
global computed_fields; %Saved img_info properties and defaults 
global statistic_fields;
global database

progress_handle = waitbar(0,'Initializing System');

database.num_images = 0;
database.num_animals = 0;
database.entry_order = [];
database.next_imgindex = 1;
database.name_to_imgindex = containers.Map('KeyType','char','ValueType','any');  

database.sample_set_str = '1:end'

%Configuration Parameters 
config.data_directory = '';
%A sample of the loaded images that will be used
config.sample_set = [];
config.sample_size = 0;

config.keypoint_detector = 'harris';
config.matching_algorithm = 'bidirectional';

waitbar(.5,progress_handle,'Loading Libraries');   


waitbar(1,progress_handle,'Finished Initialization');   


%config.data_directory = 'C:/Users/jon.crall/Dropbox/StripeSpotter/data';
%config.data_directory = 'C:/data'
%config.data_directory = 'C:/Users/jon.crall/Dropbox/StripeSpotter/data1';
config.data_directory = 'data'

if ~exist([config.data_directory],'dir')
  msgbox('This is where text will go when you run the system for the first time an informative message to help get you started :)')
  mkdir([config.data_directory]);    
end
if  ~exist([config.data_directory '/images'],'dir')
  mkdir([config.data_directory '/images']);    
end
if  ~exist([config.data_directory '/computed_info'],'dir')
  mkdir([config.data_directory '/computed_info']);        
end

close(progress_handle);
