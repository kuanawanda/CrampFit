function [ filtdata ] = filt_lp( data, n, wp )
    %FILT_HP Filters data using a low-pass Butterworth filter
    %   Frequency wp is in Hz, si in sec, n is poles

    % extract si. easier than passing each time
    si = data(2,1)-data(1,1);

    % convert from absolute frequency to 'normalized frequency'
    % which has units of pi radians / sample
    wn = wp*si/pi;

    % create the filter coefficients
    [b a] = butter(n, wn, 'low');

    % copy
    filtdata = data;
    % and replace data portion for all dimensions
    for i=2:size(filtdata,2)
        filtdata(:,i) = filtfilt(b,a,data(:,i));
    end
end
