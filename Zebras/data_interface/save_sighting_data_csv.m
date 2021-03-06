function [] = save_sighting_data_csv()
global config
global database

header = '#imgindex,original_filepath,roi,animal_name,sighting_id,flank,notes,photo_quality,sighting_date,sighting_time,exposure_time,focal_length,aperture_Fnumber,camera_info,sex,age,sighting_location,group_size,gps_lat,gps_lon,reproductive_status'

filename = [config.data_directory '/SightingData.csv'];  
fid = fopen(filename,'w');
fprintf(fid,'%s\n',header);

for i = database.entry_order
  computed = load_computed(i);
  line = [num2str(computed.imgindex) ', '...
          computed.original_filepath ', '... 
          num2str(computed.roi) ', '... 
          computed.animal_name ', '... 
          computed.sighting_id ', '... 
          computed.flank ', '... 
          computed.notes ', '... 
          computed.photo_quality ', '... 
          num2str(computed.sighting_date(1)) '-' num2str(computed.sighting_date(2)) '-' num2str(computed.sighting_date(3)) ', '... 
          num2str(computed.sighting_time(1)) ':' num2str(computed.sighting_time(2)) ', '... 
          computed.exposure_time ', '... 
          computed.focal_length ', '... 
          computed.aperture_Fnumber ', '... 
          computed.camera_info ', '... 
          computed.sex ', '... 
          computed.age ', '... 
          computed.sighting_location ', '...
          computed.group_size ', '... 
          computed.gps_lat ', '... 
          computed.gps_lon ', '... 
          computed.reproductive_status];
   fprintf(fid,'%s\n',line);
end

fclose(fid);
