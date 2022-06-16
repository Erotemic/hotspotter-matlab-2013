function [] = add_images(ImagePaths)
  global config

  previous_num_images = config.num_images;
  %Zebras are indexed as they are added. If you change the order
  %You add zebras into the database you will have to recompute everything
  for Name = ImagePaths
    config.num_images = config.num_images + 1;
    config.image_filenames = [config.image_filenames Name];
  end

  config.num_images
  set_sample_set([config.sample_set (previous_num_images+1):(config.num_images)])
