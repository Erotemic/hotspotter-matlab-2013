function [] = main(varargin)
  global config;
  disp('Starting Main');
  
  x = [2532];
  save('x.mat','x');
  
  initialize_system;

  db_window_handle = database_window();
