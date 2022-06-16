function [Image] = get_database_image(imgindex, varargin)
  global config;
  filename = sprintf('%s/images/img-%07d.jpg',config.data_directory, imgindex);

  Image = imread(filename);
  
