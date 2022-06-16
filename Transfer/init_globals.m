warning('off','MATLAB:declareGlobalBeforeUse')
global num_ground_truth;
global field_data;
global ground_truth;
global name_table;
global PathName;
global filter_type;
global table2_sorting;
global table1_sorting;
global current_match_type;
global open_files;
global options;
global radius_per_scale;
global zebra_filenames;
global num_images;

global DataDirectory; 

global MatchingInfoDir;
global sample_set;
global sample_size;
global wait_handle;

global figure_names;

wait_handle = waitbar(0,'Initializing System');


num_images = 0;

field_data.gt_index = 1;
field_data.image_id = 2;
field_data.roi_minx = 3;
field_data.roi_miny = 4;
field_data.roi_maxx = 5;
field_data.roi_maxy = 6;
field_data.name_index = 7;

radius_per_scale = 6; %Magic number used to relate the scale to the size of a vlfeat SIFT descriptor

current_match_type = 'bidirectional';
filter_type = 'same';
table2_sorting = 'None';
table1_sorting = 'None';
Prefix = 'E:/';
if ~exist('E:/Zebras')
  Prefix = 'C:/';
end
%dataset =  'sweetwaters_randomsample'
%dataset = 'mpala_randomsample'
%dataset = 'mpala_onlymatch'
%dataset = 'mpala_randomsample2'
%dataset = 'mpala_onlymatch_bigger'
%dataset = 'mpala_50_set';
%dataset = 'sweetwaters_onlymatch2'
dataset = 'PlainsZebraSet1';

PathName = [Prefix 'Zebras/' dataset '/'];

%Load in ground_truth, 
%        dataset_name,
%        field_data,
%        name_table.
zebra_filenames = [];
ground_truth = [];
name_table = [];
waitbar(.1,wait_handle,'Loading Ground Truth')
if(exist(['run ' PathName 'load_data.m']))
  %Load in the ground truth in the old style. 
  %Depricate this after you weed out all the old components
  eval(['run ' PathName 'load_data.m']);
  add_images(list_files([PathName 'images'],'jpgonly'));
  num_images = num_ground_truth;
else
  disp('Ground Truth Not Found.');
end
num_ground_truth = size(ground_truth,1);


%Add the other images
DataDirectory = [PathName 'computed_data/'];
MatchingInfoDir = [PathName 'computed_data/matches'];
waitbar(.2,wait_handle,'Loading Data')
add_images(list_files([PathName 'unknown_images'],'jpgonly'));

waitbar(.9,wait_handle,'Finishing')
%All indexing will be done in reference to the sample set
%i and j will always refer to sample indexes
%i_index and j_index will refer to real indexes
sample_set = 1:num_images;
sample_size = size(sample_set,2);

disp(['Loaded ' dataset]);

options.displayon = 1;
options.nodescriptors = 1;
options.showdescriptors = 0;
options.showallkeypoints = 0;
options.showkeypoints = 1;
options.show_keypoint_generation = 1;
options.show_raw_matches = 0;
options.keypoint_algorithm = 'harris'; %Options: harris, sift
options.matching_algorithm = 'bidirectional'; %noratio bidirectional

%Figurenames are categories of features you can use
%If you want features to have multiple figures set
%extra figures to 2 to have each figureid be a multiple
%of that number. That way you can index from the base
%category number. 
%Extra figures should only be used within one function
%multiple functions that need to use different figures
%should have different figure names
extra_figures = 4;
figure_names.keypoints           = 1 * extra_figures;
figure_names.matches             = 2 * extra_figures;
figure_names.debuging            = 3 * extra_figures;
figure_names.click_debugger      = 4 * extra_figures;
figure_names.compute_match_debug = 5 * extra_figures;
figure_names.matching_experiment = 6 * extra_figures;


close(wait_handle)
varargin = {}
