function cf = cf_launch(s)
    % CF_LAUNCH()
    % AK 20140729 launcher for graphene nanopore data
    %   
    % This is a 'launcher' file for CrampFit. It is designed to start an
    % instance of CrampFit in a specified folder and to give it the 
    % keyboard callback behavior you want.

    % this sets the default directory for File->Open
    if nargin < 1
        s = 'Z:Graphene Pores';
    end

    
    cf = CrampFit(s);
    
    % variable to hold the ranges we are trimming
    ranges = [];
    
    function keyFn(e)
        % do nothing if we don't have data loaded yet
        if isempty(cf.data)
            return
        end
        
        % to figure out what the keys are called, uncomment this line
        %disp(e);
        
        %{
        leave out range editing for now
        if strcmp(e.Character,'k')
            % remove a range of points between cursors
            xlim = cf.getCursors();
            if isempty(xlim)
                % cursors are invisible
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
        %}
    
        if strcmp(e.Character,'f')
            % create the requisite virtual signals
            
             % add 5kHz filtered data     
            f_lp = cf.data.addVirtualSignal(@(d) filt_lp(d,4,10000),'10kHz');       
            %cf.addSignalPanel(f_hpb);
            
            %define time scale for zeroed data (subtract high pass).
            maxLength = 20e-3;
            f_cutoff = 1/maxLength;
            
           
            % add panel with zeroed data     
            f_hpb = cf.data.addVirtualSignal(@(d) filt_hpb(d,4,f_cutoff),'Zeroed',f_lp);       
            cf.addSignalPanel(f_hpb);

            % WARNING - if you add other virtual signals
            % add it AFTER this one, otherwise it will 
            % mess with the event finding.
            
            disp('Filters added')
        
        elseif strcmp(e.Character,'n')
            % display a noise plot!
            
            % if cursors, do those
            tr = cf.getCursors();
            if isempty(tr)
                % otherwise, do the full view
                tr = cf.getView();
            end
            % then make a noise plot
            plot_noise(cf.data,tr);
        
        elseif strcmp(e.Character,'p')
            % load and display the pizeo
            if isempty(cf.data.filename)
                return
            end
            
            pf = [cf.data.filename '_pzt.mat'];
            if isempty(dir(pf))
                return
            end
            
            dat = load(pf);
            
            cf.addSignalPanel([]);
            ax = cf.getAxes(numel(cf.psigs));
            % don't draw smoothly interpolated lines; draw sharp jumps
            ts = cf.data.si*dat.pzt(:,1);
            zs = dat.pzt(:,2);
            % double the position and time indices
            inds = 1 + floor(0.5*(0:numel(ts)-1));
            ts = ts(inds);
            zs = zs(inds);
            % and offset by one
            ts = ts(2:end);
            zs = zs(1:end-1);
            plot(ax, ts, zs, 'r');
            cf.psigs(end).setY([0 max(zs)]);
        end
    end

    % and set our all-important keyboard callback
    cf.setKeyboardCallback(@keyFn);
end

