function zapData = find_zap(cf)
% FIND_ZAP Finds zaps for zapping file. 
% Asks user for zap information.
% Stores zap data
% Based on DNA find_event code.
%   events = find_events(cf)

% Zapping relay adds characteristic spikes -90nA, then 1 sec pause, 
% then +50nA (disconnecting, tne reconnecting the axopatch to the pore)

% We'll use those spikes to identify zaps.
% We also need to find bias switches sometimes used to check offset 
% during zapping.

% This loops through candidate zaps
% (1) Search for characteristic spikes in region between cursors
% (2) Loops through zaps and asks user to enter zap data
% (3) Adds it to the data struct

% Set up Crampfit panels in the following order:
% Panel 1: Original unfiltered data


    %%
    % Initialize    
    zapData = [];
    bias = .1; %100mV
    thickness = 0.6; %0.6 nm for graphene

    % Define event depth threshold.
    threshUp = 40;
    threshDown = -70;
    
    % Define number of samples to include before and after event
    blSamp = 1.1/cf.data.si; %equivalent to 1.1 sec
    % relay pause is 1 second
    
    % Panel 1: Unfiltered data
    orig = cf.psigs(1).sigs;

    % Set Y-scale. 
    %cf.psigs(1).resetY()
    cf.psigs(1).setY([-2 10])
    
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
    % Find the zaps

    % Start at cursor 1
    searchIdx = searchBegin;
      
    % Find first zap range. Begins at cursor, ends at first zap
    startIdx = searchBegin;
    % Take off 10 ms for end (to take out spike)
    endIdx = cf.data.findNext(@(d)...
        d(:,orig) < threshDown, searchIdx);
    
    endIdx = endIdx -.01/cf.data.si; 
                
    % define event times
    ts = cf.data.si*[startIdx endIdx];
        
    zapData(1).startIdx = startIdx;
    zapData(1).endIdx = endIdx;
    zapData(1).data = cf.data.get(startIdx:endIdx,[1 orig]);
    zapData(1).avgI = mean(zapData(1).data(:,2));           
    zapData(1).avgD = dcalc(zapData(1).avgI/bias,thickness); 
    zapData(1).tquartI = prctile(zapData(1).data(:,2),75);
    zapData(1).tquartD = dcalc(zapData(1).tquartI/bias,thickness); 
    zapData(1).bquartI = prctile(zapData(1).data(:,2),25);
    zapData(1).bquartD = dcalc(zapData(1).bquartI/bias,thickness);
    
    %draw some stuff
    h = cf.getAxes(1);
    %plot(h, [ts(1) ts(1) ts(2) ts(2)],...
    %   [-2 5 5 -2 ],'r');
    plot(h, [ts(1) ts(2)],...
       [zapData(1).tquartI zapData(1).tquartI],'g','linewidth',1); 
    plot(h, [ts(1) ts(2)],...
       [zapData(1).bquartI zapData(1).bquartI],'g','linewidth',1); 
    plot(h, [ts(1) ts(2)],...
       [zapData(1).avgI zapData(1).avgI],'k','linewidth',3); 
   
    % zapData index is i
    i = 2;
    while 1
        
        % set view to search range
        %viewt = cf.data.si*[searchBegin searchEnd];
        %cf.setView(viewt);
        cf.refresh();
        drawnow();
        
        while 1

            % Find next data exceeding threshold or return if no events
            % within 1e6 points (max length 20 sec).
            searchIdx = cf.data.findNext(@(d) d(:,orig) > threshUp |...
                d(:,1)/cf.data.si > searchIdx + 1e6, searchIdx);

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
            if searchPt(orig) > threshUp
                break
            else
                continue
            end
        end
        
        % break if reached end of search range
        if searchIdx > searchEnd
            disp('Search Completed')
            break
        elseif searchIdx < 0
            disp('Reached End of File')
            break % break if at end of file
        end
        
        % if we get here, we've found and event candidate
        % Take off 100 ms for begin (to take out spike & RC charging)
        startIdx = searchIdx + .1/cf.data.si;
        flagPt = searchIdx;
        
        % find the end of the event       
        % Take off 10 ms for end (to take out spike)
        
        endIdx = cf.data.findNext(@(d) d(:,orig) < threshDown |...
                d(:,1)/cf.data.si > startIdx + 1e6, startIdx);
        % Take off 10 ms for end (to take out spike)     
        endIdx = endIdx -.01/cf.data.si;
        
        % make sure we have an end for the event
        if endIdx < 0
            endIdx = searchEnd;
        end
        
         if endIdx > searchEnd
            %disp('Search Completed')
            endIdx = searchEnd;
         end
         
        zapData(i).startIdx = startIdx;
        zapData(i).endIdx = endIdx;
        zapData(i).data = cf.data.get(startIdx:endIdx,[1 orig]);
        zapData(i).avgI = mean(zapData(i).data(:,2));
        zapData(i).avgD = dcalc(zapData(i).avgI/bias,thickness);
        zapData(i).tquartI = prctile(zapData(i).data(:,2),75);
        zapData(i).tquartD = dcalc(zapData(i).tquartI/bias,thickness); 
        zapData(i).bquartI = prctile(zapData(i).data(:,2),25);
        zapData(i).bquartD = dcalc(zapData(i).bquartI/bias,thickness);
        
        % define event times
        ts = cf.data.si*[startIdx endIdx];
        
        % draw some stuff
        h = cf.getAxes(1);
        %plot(h, [ts(1) ts(2)],...
         %   [5 5],'r');
        plot(h, [ts(1) ts(2)],...
       [zapData(i).avgI zapData(i).avgI],'k-','linewidth',3);  
        plot(h, [ts(1) ts(2)],...
       [zapData(i).tquartI zapData(i).tquartI],'g','linewidth',1); 
        plot(h, [ts(1) ts(2)],...
       [zapData(i).bquartI zapData(i).bquartI],'g','linewidth',1); 

        % query user key input
        user_input = input('Enter zap voltage (250ns): ');
        if isempty(user_input) == 0;
            current_voltage = user_input;
        end
            zapData(i-1).voltage = current_voltage;

        i = i + 1;
        % move search cursor past event we just found
        searchIdx = searchIdx+blSamp;   
    
    end
    
    %last level has no zap
    zapData(end).voltage = [];
    
for i = 1:length(zapData)-1
   zapData(i).deltG = (zapData(i+1).avgI - zapData(i).avgI)/bias;
   zapData(i).deltD = (zapData(i+1).avgD - zapData(i).avgD);
end



end

