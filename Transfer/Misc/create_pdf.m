%Creates pdfs when input values are from 1 to M
function [pdfunc] = create_pdf(inputs,varargin)

percent_of_total = 1;
wiggle_room = 0;
for vari = 1:size(varargin,2)
  if strcmp(class(varargin{vari}),'char') & strcmp(varargin{vari},'PercentOfTotal')
    percent_of_total = varargin{vari+1};
  end
  if strcmp(class(varargin{vari}),'char') & strcmp(varargin{vari},'WiggleRoom')
    wiggle_room = varargin{vari+1};
  end
end

minval = 0;
%FIXME I changed max with 500 because the 500+ matches are wrong
maxval = 500; %max(inputs);

pdfunc = zeros(maxval,1);

for i = minval:maxval
  pdfunc(i+1) = sum(inputs == i);
end

%Smooth by weighted average
alpha = .4;
n = size(pdfunc,1);
pdfunc(2:n-1) = alpha*pdfunc(2:n-1) + (1-alpha)*0.5*(pdfunc(1:n-2)+pdfunc(3:n));

%Hack to only let wiggle room happen for the first 8 values
pdfunc(8:end) = pdfunc(8:end) + wiggle_room;
%Smooth by filtering
pdfunc = imfilter(pdfunc,[1; 1; 1; 1; 1]);
%Normalize the probability to sum to 1, and then weight it if it 
%is a conditional probability 
pdfunc = (pdfunc ./ sum(pdfunc)) .* percent_of_total;
