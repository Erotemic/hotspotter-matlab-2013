function [] = set_progress(percent, name);
persistent progress_handle;

if percent == 0
  progress_handle = waitbar(percent,name);
elseif percent < 1
  waitbar(percent,progress_handle,name);
else
  waitbar(percent,progress_handle,name);
  close(progress_handle);
end

