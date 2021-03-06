function [] = set_animal_index(index, active_pos)
global gui_properties 
global options

gui_properties.active_animal_index(active_pos) = index;

if (~isempty(gui_properties) && isfield(gui_properties,'handles') && ...
     ishandle(gui_properties.handles.animal1_selection_text) && ...
     ishandle(gui_properties.handles.animal2_selection_text))

     set( gui_properties.handles.animal1_selection_text ,'String', num2str(gui_properties.active_animal_index(1)) );
     set( gui_properties.handles.animal2_selection_text ,'String', num2str(gui_properties.active_animal_index(2)) );

     if ishandle(gui_properties.handles.image_display_axes) & index > 0
       axes(gui_properties.handles.image_display_axes);
       prim_index = gui_properties.active_animal_index(1:2 == gui_properties.active_pos);
       aux_index = gui_properties.active_animal_index(1:2 ~= gui_properties.active_pos);
       if prim_index ~= -1
         imshow(get_zebra(prim_index))
         set(gca,'XTickLabel',[])
         set(gca,'YTickLabel',[])
         set(gca,'XTick',[])
         set(gca,'YTick',[])
       end
       
       axes(gui_properties.handles.auxillary_display_axes);
       if aux_index ~= -1
         imshow(get_zebra(aux_index))
         set(gca,'XTickLabel',[])
         set(gca,'YTickLabel',[])
         set(gca,'XTick',[])
         set(gca,'YTick',[])
       end
     end
     
     %Set animal info panel
     if ishandle(gui_properties.handles.animal_info_panel) & index > 0
       set(gui_properties.handles.animal_name_text,'String',query_property(index,-1,'name'))
       set(gui_properties.handles.sighting_text,'String',num2str(query_property(index,-1,'sighting_id')))
       set(gui_properties.handles.location_text,'String',num2str(query_property(index,-1,'location')))
       set(gui_properties.handles.lat_text,'String',num2str(query_property(index,-1,'lat')))
       set(gui_properties.handles.lon_text,'String',num2str(query_property(index,-1,'lon')))
       set(gui_properties.handles.group_size_text,'String',num2str(query_property(index,-1,'group_size')))
       set(gui_properties.handles.notes_text,'String',num2str(query_property(index,-1,'notes')))
       sighting_date = query_property(index,-1,'sighting_date');
       set(gui_properties.handles.year_text,  'String', num2str(sighting_date(1)));
       set(gui_properties.handles.month_text, 'String', num2str(sighting_date(2)));
       set(gui_properties.handles.day_text,   'String', num2str(sighting_date(3)));
       set(gui_properties.handles.hour_text,  'String', num2str(sighting_date(4)));
       set(gui_properties.handles.minute_text,'String', num2str(sighting_date(5)));
       
       sex_options_button = [gui_properties.handles.male_rb gui_properties.handles.female_rb gui_properties.handles.unknown_rb];
       sex_options_name = {'Male','Female','Unknown'};
       sex_choice = strcmp(query_property(index,-1,'sex'),sex_options_name);
       set(gui_properties.handles.sex_panel,'SelectedObject',sex_options_button(sex_choice));

       flank_options_button = [gui_properties.handles.left_rb gui_properties.handles.right_rb gui_properties.handles.front_rb gui_properties.handles.back_rb];
       flank_options_name = {'Left','Right','Front', 'Back'};
       flank_choice = strcmp(query_property(index,-1,'flank'),flank_options_name);
       set(gui_properties.handles.flank_panel,'SelectedObject',flank_options_button(flank_choice))

       photo_quality_options_button = [gui_properties.handles.bad_rb gui_properties.handles.ok_rb gui_properties.handles.good_rb gui_properties.handles.best_rb];
       photo_quality_options_name = {'Bad','OK','Good','Best'};
       photo_quality_choice = strcmp(query_property(index,-1,'photo_quality'),photo_quality_options_name);
       set(gui_properties.handles.photo_quality_panel,'SelectedObject',photo_quality_options_button(photo_quality_choice))

       
       gt_id = get_gtid_from_name(query_property(index,-1,'name'));
       if gt_id == -1
           set(gui_properties.handles.is_in_database_status_text,'String','New Animal');
           set(gui_properties.handles.is_in_database_status_text,'ForegroundColor',[0 0 1]);
       else
           set(gui_properties.handles.is_in_database_status_text,'String',['Name in Database. gt_id=' num2str(gt_id)]);
           set(gui_properties.handles.is_in_database_status_text,'ForegroundColor',[1 0 0]);
       end

     end

     if get(gui_properties.handles.run_matching_experiment_toggle,'Value')
       if (gui_properties.active_animal_index(1) == -1 || gui_properties.active_animal_index(2) == -1 || gui_properties.active_animal_index(1) == gui_properties.active_animal_index(2))
         disp('Invalid Matching Experiment')
       else
         run_matching_experiment(gui_properties.active_animal_index(1), gui_properties.active_animal_index(2))
         figure(gui_properties.handles.figure1)
       end
     end
end



