function DNAevent = find_events(cf)
%FIND_EVENTS Finds events and returns an array of DNAevent structs
%   events = find_events(cf)
%   This is just an example of how to use CrampFit.
%   AK 20140727 for finding events with graphene nanopores

    DNAevent = [];

    % Define event depth threshold.
    thresh = 1.0;
    
    % use the signal specified in the second panel of CrampFit for the
    % event finding. you'd probably just hardcode this in your own code.
    sig = cf.psigs(2).sigs;

    % loop through section between cursors
    curs = getCursors(cf);
    cursIdx = curs/cf.data.si;
    searchBegin = cursIdx(1);
    searchEnd = cursIdx(2);
    
    searchIdx = cursIdx(1);
    
    while 1
        % find next data exceeding threshold, stepping current index
        searchIdx = cf.data.findNext(@(d) d(:,sig) < -1*thresh, searchIdx);
        
        % if we didn't find any, we're done with the file
        if searchIdx < 0
            break
        end
        
        imin = searchIdx;
        % find the end of the event
        imax = cf.data.findNext(@(d) d(:,sig) > -0.75*thresh,searchIdx);
        
        % make sure we have an end for the event
        if imax < 0
            break
        end
        
        % shift event by one sample in each directon to get whole event
        imin = imin-1;
        imax = imax+1;
        
        % and move curind too
        searchIdx = imax;
        
        % event? maybe event?
        ts = cf.data.si*[imin imax];
        
        % time range to view, extended past the event a bit
        %viewt = [ts(1)-0.001, ts(2)+0.001];
        viewt = [searchBegin searchEnd];
        
        % we've decided we have a possibly good event, then
        dna = [];
        
        % store the data we want, including times
        % note that we're only grabbing the signal we're analyzing
        dna.data = cf.data.get(imin:imax,[1 sig]);

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
            [0 0 dna.blockage dna.blockage 0 0],'r');
        % this line ignores the stuff you drew, in case you're wondering
        cf.autoscaleY();
        % do this just for kicks
        cf.setCursors(ts);
        
        % if you want it to run automatically, this would be the part you
        % would change, or something
        k = cf.waitKey();
        % clear, and force a redraw. this way, you don't accidentally press
        % keys twice because you don't know if it's thinking or not.
        cf.clearAxes();
        pause(0.01);
        
        % handle key input
        if (k == 'q')
            return
        elseif (k ~= 'y')
            continue
        end
        
        % stupid matlab structs bug
        if isempty(DNAevent)
            DNAevent = dna;
        else
            DNAevent(end+1) = dna;
        end
    end
end

