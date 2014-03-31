function cf = cf_launch(fname)

    % load a file, if given
    if (nargin > 0)
        cf = CrampFit(fname);
    else
        cf = CrampFit();
    end
    
    % variable to hold the ranges we are trimming
    ranges = [];
    
    function keyFn(e)
        % do nothing if we don't have data loaded yet
        if isempty(cf.data)
            return
        end
        
        % to figure out what the keys are called
        %disp(e);
        
        if strcmp(e.Character,'k')
            % remove a range of points between cursors
            xlim = cf.getCursors();
            if isempty(xlim)
                % invisible
                return
            end
            
            % get average of endpoints, in a narrow range around them
            y0s = mean(cf.data.getByTime(xlim(1),xlim(1)+0.001));
            y1s = mean(cf.data.getByTime(xlim(2),xlim(2)-0.001));
            % and their average
            yave = mean([y0s; y1s]);
            % and add it to ranges
            ranges(end+1,:) = [xlim yave(2:cf.data.nsigs+1)];
            % update virtual signal
            cf.data.addVirtualSignal(@(d) filt_rmrange(d,ranges),'Range-edited');
            % and refresh visible points
            cf.refresh();
            % and display some stuff
            fprintf('Removed %f to %f\n',xlim(1),xlim(2));
            
        elseif strcmp(e.Character,'f')
            % create the requisite virtual signals
            
            % subselected data filter
            f_rm = cf.data.addVirtualSignal(@(d) filt_rmrange(d,ranges),'Range-edited');
            % high pass acts on subselected data
            f_hp = cf.data.addVirtualSignal(@(d) filt_hp(d,4,100),'High-pass',f_rm);
            % tell median to act on high-passed data
            f_med = cf.data.addVirtualSignal(@(d) filt_med(d,15),'Median',f_hp);
            
            % also set which signals to draw in each panel
            cf.psigs(1).sigs = f_rm(1);
            % draw both median-filtered panels
            cf.addSignalPanel(f_med);

            disp('Filters added')
        
        elseif strcmp(e.Character,'n')
            % if cursors, do those
            tr = cf.getCursors();
            if isempty(tr)
                tr = cf.getView();
            end
            % then make a noise plot
            plot_noise(cf.data,tr);
        end
    end

    % and set our all-important keyboard callback
    cf.setKeyboardCallback(@keyFn);
end

