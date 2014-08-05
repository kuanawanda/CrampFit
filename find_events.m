function DNAevent = find_events(cf)
%FIND_EVENTS Finds events and returns an array of DNAevent structs
%   events = find_events(cf)

% This loops through candidate DNA translocation events
% (1) Searched for events in zeroed data
% (2) Zooms in and looks more carefully in the original data
% (3) Shows it to user and allows accept/reject
% (4) Adds it to the data struct or not

% Set up Crampfit panels in the following order:
% Panel 1: Original unfiltered data
% Panel 2: Zeroed data (data - high passed data), gets rid of offset

    %%
    % Initialize
    
    DNAevent = [];

    % Define event depth threshold.
    thresh = 1.65;
    
    % Define number of samples to include before and after event
    blSamp = 1000; %equivalent to 2ms
    
    % Panel 1: Unfiltered data
    % Panel 2: Zeroed 
    orig = cf.psigs(1).sigs;
    zerod = cf.psigs(2).sigs;

    % Set Y-scale. 
    cf.psigs(1).resetY()
    cf.psigs(2).setY([-6 3])
    
    % Get cursor data
    curs = cf.getCursors();
    if isempty(curs)
        curs = [cf.data.tstart cf.data.tend];
    end
    cursIdx = curs/cf.data.si;
    searchBegin = cursIdx(1);
    searchEnd = cursIdx(2);
    
    cf.clearAxes();    
    %% 
    % Loop through candidate events

    % Start at cursor 1
    searchIdx = cursIdx(1);

    while 1
        
        % set view to search range
        viewt = cf.data.si*[searchBegin searchEnd];
        cf.setView(viewt);
        cf.refresh();
        drawnow();
        
        % First, find event in zeroed data.
        
        while 1
            % Find next data exceeding threshold or return if no events
            % within 1e5 points.
            searchIdx = cf.data.findNext(@(d) d(:,zerod) < -1*thresh |...
                d(:,1)/cf.data.si > searchIdx + 1e5, searchIdx);

            % break if reached end of file or end of search range
            if searchIdx < 0 | searchIdx > searchEnd
                break
            end

            % move cursor 1 to current search position and redraw
            cf.setCursors(cf.data.si*[searchIdx searchEnd]);
            cf.refresh();
            drawnow();

            % if we actually found an event, leave loop
            searchPt = cf.data.get(searchIdx);
            if searchPt(zerod) < -1*thresh
                break
            else
                continue
            end
        end
        
        % break if reached end of search range
        if searchIdx > searchEnd
            disp('Search Completed')
            break
        else if searchIdx < 0
            disp('Reached End of File')
            break % break if at end of file
        end
        
        
        
        % if we get here, we've found and event candidate
        startIdx = searchIdx;
        flagPt = searchIdx;
        
        % find the end of the event
        endIdx = cf.data.findNext(@(d) d(:,zerod) > -0.25*thresh |...
                d(:,1)/cf.data.si > startIdx + 1e5, startIdx);
        
        % make sure we have an end for the event
        if endIdx < 0
            break
        end
        
        % define event times
        ts = cf.data.si*[startIdx endIdx];
        
        % time range to view, 2*blSamp before and after event
        viewt = cf.data.si*[startIdx-2*blSamp endIdx+2*blSamp];
        cf.setView(viewt);
                
        %{
        % we've decided we have a possibly good event, then
        dna = [];
        
        % store the data we want, including times
        % note that we're only grabbing the signal we're analyzing
        dna.data = cf.data.get(startIdx:endIdx,[1 zerod]);

        % and the start and end times for the event
        dna.tstart = ts(1);
        dna.tend = ts(2);

        % the average current blockage
        dna.blockage = abs(mean(dna.data(:,2)));
        
        % now query on-screen, see what we think
        % first, zoom in
        cf.setView(viewt);
        
        % then, draw some stuff
        h = cf.getAxes(2);
        plot(h, [viewt(1) ts(1) ts(1) ts(2) ts(2) viewt(2)],...
            [0 0 -dna.blockage -dna.blockage 0 0],'r');
        %}
        
        % Now go to original data to fit event
        
        % pull out samples before and after event
        % to get baseline
        blBefore = cf.data.get(startIdx-2*blSamp:startIdx-blSamp,[1 orig]);
        blAfter = cf.data.get(endIdx+blSamp:endIdx+2*blSamp,[1 orig]);
        avgBefore = mean(blBefore(:,2));
        avgAfter = mean(blAfter(:,2));
        bl = (avgBefore + avgAfter) / 2; 
        cf.psigs(1).setY([-6+bl 3+bl]);
        cf.psigs(2).setY([-6 3]);
        
    
        % draw avgBefore and avgAfter
        h = cf.getAxes(1);
        plot(h,cf.data.si*[startIdx-2*blSamp startIdx-blSamp],...
            [avgBefore avgBefore],'r');
        plot(h, cf.data.si*[endIdx+blSamp endIdx+2*blSamp],...
            [avgAfter avgAfter],'r');
    
        
        % use a more aggressive threshold, allow user to make sure we don't
        % catch a local noise spike instead of event.
       
            % run local search in orig (unzeroed) data
            % to get more accurate event start/end
            searchIdx = startIdx - 2*blSamp;
            
        while 1
            cf.clearAxes();
            cf.refresh();
            drawnow();
            
            % find the event start
            searchIdx = cf.data.findNext(@(d) d(:,orig) < bl-0.25*thresh...
                | d(:,1)/cf.data.si > searchIdx + 1e5, searchIdx); 
                % use 25% of thresh to catch begin

            % if we didn't find any, we're in trouble
            if searchIdx < 0
                break
            end

            startIdx = searchIdx;
        
            % find the end of the event
            endIdx = cf.data.findNext(@(d) d(:,orig) > bl - 0.25*thresh |...
                d(:,1)/cf.data.si > startIdx + 1e5, startIdx);

            % if we dont' have an end, we're also in trouble 
            if endIdx < 0
                break
            end
      
            % define event times
            ts = cf.data.si*[startIdx endIdx];

            % initialize a new dna event entry
            dna = [];

            % store the data we want
            dna.data = cf.data.get(startIdx-2*blSamp:endIdx+2*blSamp,[1 orig]);
            dna.baseline = bl;
            dna.dataZeroed = dna.data - bl;

            % store start and end times for the event
            dna.tstart = ts(1);
            dna.tend = ts(2);
            dna.length = ts(2)-ts(1);

            % store average current blockage
            dna.datashort = cf.data.get(startIdx:endIdx,[1 orig]);
            dna.blockage = abs(mean(dna.datashort(:,2))-bl);
            
            % if dna blockage is too small, skip this find and keep
            % looking.
            if dna.blockage < 0.5*thresh
                searchIdx = endIdx;
                if searchIdx > flagPt + 3*blSamp;
                    break
                else
                    continue
                end
            end
       
            
            % now draw the fit on screen
            viewt = cf.data.si*[startIdx-2*blSamp endIdx+2*blSamp];
            cf.setView(viewt);
            h = cf.getAxes(1);
            plot(h, [viewt(1) ts(1) ts(1) ts(2) ts(2) viewt(2)],...
                [bl bl bl-dna.blockage bl-dna.blockage bl bl],'g');

            % query user key input
            disp(['Event found at t = ' num2str(dna.tstart)]);
            disp('Press any key to accept, "r" to reject, "z" to skip noise');
            k = cf.waitKey();

            % handle key input
            if (k == 'z')
                % move search cursor up 
                searchIdx = searchIdx + 20;
                continue
            else
                % move search cursor past event we just found
                searchIdx = flagPt+dna.length/cf.data.si;
                break
            end
        end
       
            
        % handle key input
        if (k == 'q')
            return
        elseif (k == 'r')
            disp('Event Discarded');
            continue
        end
    
        % save DNA data if it's a good event
        if isempty(DNAevent)
            DNAevent = dna;
        else
            DNAevent(end+1) = dna;
        end

    end
end

