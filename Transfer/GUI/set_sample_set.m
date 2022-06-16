function [] = set_sample_set(new_sample_set)
global config
global gui_properties

population = 1:config.num_images;

if strcmp(class(new_sample_set),'char')
    eval(['config.sample_set = population(' new_sample_set ');']);
else
  config.sample_set = population(new_sample_set);
end


config.sample_size = size(config.sample_set,2);

if (~isempty(gui_properties) && isfield(gui_properties,'handles') && ishandle(gui_properties.handles.sample_set_text))

  set(gui_properties.handles.sample_set_text,'String',['[' num2str(config.sample_set) ']'])


  set_animal_index(-1,1);
  set_animal_index(-1,2);
  set_image_table_values()

  
end

