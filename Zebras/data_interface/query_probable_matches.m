function [queried_image] = query_probable_matches(query_animal_info,varargin)
global database

%The query index is used as a temporary index 
%Where all query info is saved. It becomes perminante if 
%the query is added to the database
query_index = database.next_imgindex;


roi = query_animal_info.roi;
image = query_animal_info.image;
[rsize csize dim] = size(image);

x1 = fix(max(roi(1), 1));
y1 = fix(max(roi(2), 1));
x2 = fix(min(roi(3)+x1,csize));
y2 = fix(min(roi(4)+y1,rsize));
cropped_image = image(y1:y2,x1:x2,1:dim);

if isempty(query_animal_info.keypoints)
    [k d] = compute_keypoints_and_descriptors(cropped_image);
    query_animal_info.keypoints = k;
    query_animal_info.descriptors = d;
end

progress_handle = waitbar(0, 'Finding Probable Matches');

db_sample = 1:database.num_images;
db_sample = eval(['db_sample(' database.sample_set_str ');']);
db_sample_size = size(db_sample,2);

for i = 1:db_sample_size %Test on the first 10 images only database.num_images
  waitbar(i/db_sample_size,progress_handle,'Finding Probable Matches');
  db_index = database.entry_order(db_sample(i));
  computed = load_computed(db_index);
  
  if isempty(computed.keypoints)
    db_image = get_database_image(db_index);
    if ~isempty(computed.roi)
      [rsize_c csize_c dim_c] = size(db_image);
      x1_c = fix(max(computed.roi(1), 1));
      y1_c = fix(max(computed.roi(2), 1));
      x2_c = fix(min(computed.roi(3)+x1_c,csize_c));
      y2_c = fix(min(computed.roi(4)+y1_c,rsize_c));
      db_image = db_image(y1_c:y2_c,x1_c:x2_c,1:dim_c);
    end
    waitbar(i/db_sample_size,progress_handle,'Finding Probable Matches... This may take awhile');  
    [k d] = compute_keypoints_and_descriptors(db_image,'disable_progress');
    computed.keypoints = k;
    computed.descriptors = d;
    save_computed(computed,'write');
  end
  
  [matches] = get_computed_match(computed,query_animal_info,'disable_progress');
  computed.num_matches(query_index) = size(matches,2);
  save_computed(computed,'write');
  query_animal_info.num_matches(db_index) = size(matches,2);
end
         
close(progress_handle)
disp('Finished query');

queried_image = query_animal_info;
