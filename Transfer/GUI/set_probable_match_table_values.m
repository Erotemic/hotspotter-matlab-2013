function [] = set_probable_match_table_values()
global gui_properties
global config

query_index = gui_properties.active_animal_index(1:2 == gui_properties.active_pos);
%Set up the column names and allocate space for their data
table_columnnames = {'ImgId','Probability','NumMatches'};
num_table_columnss = size(table_columnnames,2);
table_column_data = cell(config.sample_size,num_table_columnss);

%Filtered indexes keep track of where we are 
%When not adding every piece of data
filtered_index = 1;

%Create data for each entry in each table
for i = 1:config.sample_size
  img_id = config.sample_set(i);
  i
  query_index
  match_probability = query_property(query_index,i,'probability_match');
  num_matches = query_property(query_index,i,'num_matches');

  %Image Table Values
  table_column_data{filtered_index,1} = img_id;
  table_column_data{filtered_index,2} = match_probability;
  table_column_data{filtered_index,3} = num_matches;


  filtered_index = filtered_index + 1;
end

%Sort by probability and then matches
table_column_data = flipud(sortcell(table_column_data,[2 3]));

%if strcmp(table1_sorting,'Most Matches')
%  table_column_data = flipud(sortcell(table_column_data,5));
%elseif strcmp(table2_sorting,'Least Matches')
%  table_column_data = sortcell(table_column_data,5);
%end
%if strcmp(table2_sorting,'Most Matches')
%  table2_column_data = flipud(sortcell(table2_column_data,4));
%elseif strcmp(table2_sorting,'Least Matches')
%  table2_column_data = sortcell(table2_column_data,4);
%end

if (~isempty(gui_properties) && ~isempty(table_column_data) && isfield(gui_properties,'handles') && ishandle(gui_properties.handles.data_directory_text))
  %Give the data to the uitables
  set(gui_properties.handles.probable_matches_table,...
      'ColumnName',     table_columnnames,...
      'ColumnEditable', logical(zeros(1,num_table_columnss)),...%Set to all false
      'Data',           table_column_data);
end

