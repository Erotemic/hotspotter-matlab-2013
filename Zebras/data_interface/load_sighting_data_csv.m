function [] = load_sighting_data_csv()
global config

filename = [config.data_directory '/SightingData.csv'];  
config.data_directory

if ~exist(filename)
  return
end


%sighting_data = importdata(filename,',',1)

%imgindex,original_filepath,roi,animal_name,sighting_id,flank,notes,photo_quality,sighting_date,sighting_time,exposure_time,focal_length,aperture_Fnumber,camera_info,sex,age,sighting_location,group_size,gps_lat,gps_lon,reproductive_status
%sighting_data.textdata{1,1}

progress_handle = waitbar(0,'Reading sighting data');
%sighting_data_lines = textread(filename,'%s','delimiter','\n');

fid = fopen(filename);

fseek(fid,0,'eof');
total_bytes = ftell(fid);
fseek(fid,0,'bof');
line = fgetl(fid);%Skip first line
line = fgetl(fid);
%for i = 2:size(sighting_data_lines,1)
while line ~= -1
    
  sighting_data = strread(line,'%s','delimiter',',');
  sighting_data
  animal_info = struct;
  animal_info.imgindex            = str2num(sighting_data{1});
  animal_info.original_filepath   = sighting_data{2};
  animal_info.roi                 = str2num(sighting_data{3});
  animal_info.animal_name         = sighting_data{4};
  animal_info.sighting_id         = sighting_data{5};
  animal_info.flank               = sighting_data{6};
  animal_info.notes               = sighting_data{7};
  animal_info.photo_quality       = sighting_data{8};
  animal_info.sighting_date       = sighting_data{9};
  animal_info.sighting_time       = sighting_data{10};
  animal_info.exposure_time       = sighting_data{11};
  animal_info.focal_length        = sighting_data{12};
  animal_info.aperture_Fnumber    = sighting_data{13};
  animal_info.camera_info         = sighting_data{14};
  animal_info.sex                 = sighting_data{15};
  animal_info.age                 = sighting_data{16};
  animal_info.sighting_location   = sighting_data{17};
  animal_info.group_size          = sighting_data{18};
  animal_info.gps_lat             = sighting_data{19};
  animal_info.gps_lon             = sighting_data{20};
  if size(sighting_data,1) == 21
    animal_info.reproductive_status = sighting_data{21};
  end
  add_image_to_database(animal_info);
  waitbar(ftell(fid)/total_bytes,progress_handle,'Reading sighting data');
  line = fgetl(fid);
  
end

fclose(fid);

close(progress_handle);

