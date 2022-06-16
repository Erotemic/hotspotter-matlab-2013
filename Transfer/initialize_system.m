warning('off','MATLAB:declareGlobalBeforeUse')
global figure_names; %Makes sure figures don't overlap with each other
global config; %Configuration Parameters. 
global computed_fields; %Saved img_info properties and defaults 
global statistic_fields;
global radius_per_scale; %Should be moved out of here later

progress_handle = waitbar(0,'Initializing System');

%Magic number used to relate the scale to the size of a vlfeat SIFT descriptor
radius_per_scale = 6; 


%Configuration Parameters 
config.data_directory = '';
%A list of all loaded images
config.image_filenames = []; 
config.num_images = 0; 
%A sample of the loaded images that will be used
config.sample_set = [];
config.sample_size = 0;

config.keypoint_detector = 'harris';
config.matching_algorithm = 'bidirectional';

waitbar(.5,progress_handle,'Loading Libraries');   

%CONSTANT GLOBALS
extra_figures = 4;
figure_names.keypoints           = 1 * extra_figures;
figure_names.matches             = 2 * extra_figures;
figure_names.debuging            = 3 * extra_figures;
figure_names.click_debugger      = 4 * extra_figures;
figure_names.compute_match_debug = 5 * extra_figures;
figure_names.matching_experiment = 6 * extra_figures;

computed_fields = {'keypoints',-1;...
                   'descriptors',[];...
                   'largest_keypoint_cluster',-1;...
                   'name','unknown';...
                   'sighting_id',-1;...
                   'location','';...
                   'lat',nan;...
                   'lon',nan;...
                   'group_size',0;...
                   'flank','';...
                   'sex','Unknown';...
                   'photo_quality','';...
                   'sighting_date',datevec(0);...
                   'notes','';...
                   'img_id',-1;...
                   'original_image_location',''}';

statistic_fields = {'num_matches';...
                    'probability_match';...
                    'num_inliers';...
                    'similarity'};

waitbar(.5,progress_handle,'Finished Initialization');   
close(progress_handle);
