function [ filtdata ] = filt_zeroed( data, n)
    %FILT_zeroed removes a wandering open pore current by subtracting 
    %a smoothed version of the data with n-point smoothing

    % copy
    filtdata = data;
    % and replace data portion for all dimensions
    for i=2:size(filtdata,2)
        filtdata(:,i) = data(:,i)-smooth(data(:,i),n);
    end
end
