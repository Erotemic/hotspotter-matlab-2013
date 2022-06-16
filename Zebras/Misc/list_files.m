function [files] = list_files(d,varargin)

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

just_name = 0;
jpg_only = 0;
image_only = 1;
recursive = 0;

for k = 1:size(varargin,2)
  if strcmp(varargin{k},'justname')
    just_name = 1;
  end
  if strcmp(varargin{k},'jpgonly')
    jpg_only = 1;
  end
  if strcmp(varargin{k},'recursive')
    recursive = 1;
  end
  if strcmp(varargin{k},'image_only')
    jpg_only = 1;
  end
end

files = [];

o = dir(d);

for i = 1:size(o)
  if strcmp(o(i).name, '.') == 1 | strcmp(o(i).name, '..') == 1
    continue
  elseif o(i).isdir
    if recursive
      files = [files; list_files(strcat(d,'/',o(i).name),varargin)];
    end
  else
    [pathstr,name,ext] = fileparts(strcat(d,'/',o(i).name));    
    if image_only
      if ~strcmp(ext,'.jpg') & ~strcmp(ext,'.jpeg') & ~strcmp(ext,'.png')
        continue
      end
    end
    if jpg_only
      if ~strcmp(ext,'.jpg') & ~strcmp(ext,'.jpeg')
        continue
      end
    end   
    if just_name == 0
      files = [files; {strcat(d,'/',o(i).name)}];
    else 
      files = [files; {name}];
    end
  end
end

end
