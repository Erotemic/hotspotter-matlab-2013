%Expects and returns data ordered in rows. Nx1
function [return_peaks] = peakfinder2(data, neighborhood_radius, thresh_of_max, varargin)

  invalid_peaks = [];
  fig = -1;
  sub_peak_least_squares = 0;
  sub_peak_polynomial = 0;

  for var_index = 1:size(varargin,2)
    var = varargin{var_index};
    if strcmp(var,'invalid_peaks')
      invalid_peaks = varargin{var_index+1};
    end
    if strcmp(var,'figure')
      fig = varargin{var_index+1};
    end
    if strcmp(var,'sub_peak_least_squares')
      sub_peak_polynomial = 1;
    end
    if strcmp(var,'sub_peak_polynomial')
      sub_peak_polynomial = 1;
    end
  end


  %Find the local maxima using whatever method
  neighborhood_diameter = neighborhood_radius*2 + 1;
  highest       = ordfilt2(data, neighborhood_diameter, ones(neighborhood_diameter,1));
  second_highest = ordfilt2(data, neighborhood_diameter-1, ones(neighborhood_diameter,1));
  peak_loc_pre_thresh = find(highest==data & highest~=second_highest);
  %'===='
  %[~, peak_loc_pre_thresh] = findpeaks(data,'MINPEAKDISTANCE',min(size(data,1)-1,neighborhood_diameter));
  %peak_loc_pre_thresh = peak_loc_pre_thresh';
  %Remove any invalid peaks
  peak_loc_pre_thresh = setdiff(peak_loc_pre_thresh,invalid_peaks);
  %Remove peaks that are below a threshold
  max_peak = max(data(peak_loc_pre_thresh));
  thresh =  (thresh_of_max*max_peak);
  peak_loc = peak_loc_pre_thresh(data(peak_loc_pre_thresh) > thresh);

  return_peaks = peak_loc;

  % Subpeak interpolation is requested using the
  % least squares method
  t_sels = [];
  if (sub_peak_least_squares && ~isempty(peak_loc))

    
    sub_peak_loc = zeros(size(peak_loc));
    sub_peak_coeff = zeros(size(peak_loc,1),3);  %Save the coefficients for graphing later
    t = (1:size(data,1))';
    y = data;
    lst_sqrts_data_neighborhood = 1; %Number of steps to look around the maximum in both directions
    t_neighborhood = -lst_sqrts_data_neighborhood:lst_sqrts_data_neighborhood;
    t_sels = (repmat(t_neighborhood,[size(peak_loc,1), 1]) + repmat(peak_loc,[1 size(t_neighborhood,2)]))';

    peak_index = 1;
    for t_sel = t_sels

      [sub_peak, ~, coeff] = crit_interp_p(y(t_sel),t(t_sel))
      
      %Fit a second order polynomial to the data around a maximum
      %coeff = polyfit(t(t_sel),y(t_sel),2);
      sub_peak_coeff(peak_index,:) = coeff;
      sub_peak_loc(peak_index) = sub_peak;
      %Find the maximum of that polynomial. (set deriv to 0)
      %sub_peak_loc(peak_index) = -coeff(2)./(2*coeff(1));
      peak_index = peak_index + 1;
    end
    sub_peak_loc
    sub_peak_loc1
    return_peaks = sub_peak_loc;
  elseif (sub_peak_polynomial && ~isempty(peak_loc))
    sub_peak_loc = zeros(size(peak_loc));
    sub_peak_coeff = zeros(size(peak_loc,1),3);  %Save the coefficients for graphing later
    t = (1:size(data,1))';
    y = data;
    t_sels = (repmat([-1 0 1],[size(peak_loc,1), 1]) + repmat(peak_loc,[1 3]))';
    peak_index = 1;
    for t_sel = t_sels
      [sub_peak, ~, coeff] = crit_interp_p(y(t_sel),t(t_sel));
      sub_peak_coeff(peak_index,:) = coeff;
      sub_peak_loc(peak_index) = sub_peak;
      peak_index = peak_index + 1;
    end
    return_peaks = sub_peak_loc;
  end

  if (nargout == 0 || fig ~= -1)
    if fig ~= -1
      figure(fig);
    else
      figure;
    end
    plot(data,'.-');
    hold on;
    data(peak_loc);
    plot(peak_loc, data(peak_loc),'ro')

    if sub_peak_least_squares
      peak_index = 1;
      for t_sel = t_sels
        coeff = sub_peak_coeff(peak_index,:); %Get the saved coefficients for this radius
        t2 = (t_sel(1):.1:t_sel(end));
        y2 = polyval(coeff,t2);
        max_x = sub_peak_loc(peak_index);
        %max_x = -coeff(2)./(2*coeff(1));
        max_y = coeff(1).*(max_x.^2) + (coeff(2).*max_x) + coeff(3);
        max_y = polyval(coeff,max_x);

        plot(t2, y2,'r-')
        plot(max_x,max_y,'gx')
        plot(max_x,max_y,'ro')
        peak_index = peak_index + 1;
      end
    end
  end
