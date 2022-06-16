function [] = add_image_to_database(animal_info)
global database
global config

database.num_images = database.num_images + 1;
%Give the animal a new image id
if animal_info.imgindex == -1
  animal_info.imgindex = database.next_imgindex;
end

database.next_imgindex = max(database.next_imgindex + 1, animal_info.imgindex);


%Add the name table
if ~database.name_to_imgindex.isKey(animal_info.animal_name)
  %New animal name
  database.num_animals = database.num_animals + 1;
  database.name_to_imgindex(animal_info.animal_name) =  [animal_info.imgindex];
  %Save imgindexes in an array that is gaurenteed to be indexed consistently  
  %In an ideal situation database.entry_order(animal_info.imgindex) == animal_info.imgindexim
  animal_info.entry_num = database.num_images;
  database.entry_order = [database.entry_order animal_info.imgindex];
else
  %New instance of previously known animal
  if find(database.name_to_imgindex(animal_info.animal_name)==animal_info.imgindex)
    disp(['animal ' num2str(animal_info.imgindex) 'is already in the database'])
    database.num_images = database.num_images - 1;
  else
    database.entry_order = [database.entry_order animal_info.imgindex];
    animal_info.entry_num = database.num_images;
    database.name_to_imgindex(animal_info.animal_name) = [database.name_to_imgindex(animal_info.animal_name), animal_info.imgindex];
  end
end

%Copy original image into image directory if not there
if isempty(animal_info.original_filepath)
  ext = '.jpg';
else
  [~, ~, ext] = fileparts(animal_info.original_filepath);
end
database_image = sprintf('%s/images/img-%07d%s', config.data_directory, animal_info.imgindex, ext);


if ~exist(database_image,'file')
  if ~exist(animal_info.original_filepath,'file')
    disp(['Error: Original and database image for animal "' num2str(animal_info.imgindex) '" does not exist']);
    msgbox(['Error: Original and database image for animal "' num2str(animal_info.imgindex) '" does not exist']);
  else
    copyfile(animal_info.original_filepath, database_image);
  end
end

%If this is the first time computing this data write the data 
%to disk. TODO this should also be able to overwrite old values if necessary.
computed_filename = sprintf('%s/computed_info/computed-%07d.mat',config.data_directory, animal_info.imgindex);
if ~exist(computed_filename,'file') | 1
  [computed isnew] = load_computed(animal_info.imgindex);
  for field = fieldnames(animal_info)'
    computed = setfield(computed, field{1}, getfield(animal_info,field{1}) ) ;
  end
  %Force a valid ROI
  if isempty(computed.roi)
    [rsize csize ~] = size(get_database_image(computed.imgindex));
    computed.roi = [1 1 csize rsize];
  end
  animal_info = computed;
  %Save to disk 
  save_computed(animal_info,'write');
end
