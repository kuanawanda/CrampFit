function zapPlot(zapData, voltage_select);
% Takes data from analyzed zap data (function find_zap) and plots various
% parameters.
thickness = .6;

% voltage_select is which voltage pulses to examine: usually 5 V.

% Read in data struct
for i = 1:length(zapData)
    % delta fields have empty first entry.
    if i > 1;
        % voltage field has empty first entry.
        voltage(i) = zapData(i).voltage;
        all_deltG(i) = zapData(i).deltG;
        all_deltD(i) = zapData(i).deltD;
     end

    G(i) = zapData(i).avgI;
    D(i) = zapData(i).avgD;
    tquartG(i) = zapData(i).tquartG;
    tquartD(i) = zapData(i).tquartD;
    bquartG(i) = zapData(i).bquartG;
    bquartD(i) = zapData(i).bquartD;
end

%{
%% Electrical Pulse Histogram - Conductance

deltG = all_deltG(voltage == voltage_select);

pHistCond = findobj('Name','Electrical Pulse Histogram - Conductance');
    if isempty(pHistCond)
        pHistCond = figure('Name','Electrical Pulse Histogram - Conductance','NumberTitle','off');
    end
figure(pHistCond);    
Gstep = -10:1:10;
hist(deltG,Gstep);
xlabel ('Change in Conductance (nS)','FontSize', 20);
ylabel ('Number of Pulses','FontSize', 20);

%}

%% Electrical Pulse Histogram - Diameter

% select only those pulses after a given voltage pulse
IdxSelect = abs(voltage) == voltage_select;
deltD = all_deltD(IdxSelect);

% Have to be careful - want levels BEFORE zaps, not after
% Shift Index Select by 1
IdxSelect(1) = [];
Dselect = D(IdxSelect);


pHistD = findobj('Name','Electrical Pulse Histogram - Diameter');
    if isempty(pHistD)
        pHistD = figure('Name','Electrical Pulse Histogram - Diameter','NumberTitle','off');
    end
figure(pHistD);

% plot histogram
Dstep = -2:.1:2;
[bincounts] = histc(deltD, Dstep);
bar(Dstep,bincounts/(length(deltD)*.1))
hold on;

% plot fitted normal function
x = -2:.01:2;
avg = mean(deltD);
sd = std(deltD);
y = normpdf(x,avg,sd);
plot(x,y,'r-','linewidth',2);

% Plot vertical line at deltDavg
hx = graph2d.constantline(avg, 'LineStyle','--','Linewidth',2','Color','r');
changedependvar(hx,'x');

set(gca,'XTick',[-1:1:4]);
grid on;
hold off;

%label axes
xlabel ('Change in Diameter (nm)','FontSize', 20);
ylabel ('Normalized Probibility','FontSize', 20);


%% D vs Delta D plot
% To see if the delt D cares about how big the pore is

DvDeltD = findobj('Name','deltD vs D');
    if isempty(DvDeltD)
        DvDeltD = figure('Name','deltD vs D','NumberTitle','off');
    end
figure(DvDeltD);

plot(Dselect, deltD,'ko');
[p,S,mu] = polyfit(Dselect,deltD,1);
line([min(Dselect) max(Dselect)],[p(1)*min(Dselect)+p(2)...
    p(1)* max(Dselect)+p(2)],'linewidth',1);
%line([min(Dselect) max(Dselect)],[0 0],'linewidth',1,'color','k');
%# horizontal line
hy = graph2d.constantline(0, 'Color','k');
changedependvar(hy,'y');

xlabel ('Diameter (nm)','FontSize', 20);
ylabel ('Change in Diameter (nm)','FontSize', 20);
%[deltD,delta] = polyval(p,Dselect,S,mu)


%%

epf = findobj('Name','Electrical Pulse Fabrication - Diameter');
    if isempty(epf)
        epf = figure('Name','Electrical Pulse Fabrication - Diameter','NumberTitle','off');
    end
figure(epf);  

cmap = colormap(hot(10));
set(colorbar,'YTick',[1:1:6])

hold on;

markersize = 15;

for i = 2:length(G)
    
    %quadrilateral indicating errors also
    fillx = [i-1 i-1 i i];
    filly = [real(bquartG(i-1)) real(tquartG(i-1)) real(tquartG(i)) real(bquartG(i))];
    fillcolor=cmap(ceil(abs(voltage(i))),:,:);
    fill(fillx, filly,fillcolor,'LineWidth',1);
   
    %{
    %line([i-1, i],[G(i-1),G(i)],'color',cmap(ceil(abs(voltage(i))),:,:),'linewidth',3);
    %line([i,i],[real(bquartG(i)), real(tquartG(i))],'color','black','linewidth',2);
    scatter(i-1,G(i-1),markersize,'MarkerFaceColor','black',...
        'MarkerEdgeColor','black','linewidth',1);
    %}
end
    %{
    fin = length(G);
    line([fin,fin],[bquartG(fin), tquartG(fin)],'color','black','linewidth',1);

    scatter(fin,real(G(fin)),markersize,'MarkerFaceColor','black',...
        'MarkerEdgeColor','black','linewidth',1);
    %}

colorbar('Location','NorthOutside','XTickLabel',...
    {'1 V','2 V','3 V','4 V',...
     '5 V','6 V','7 V','8 V','9 V','10V'})
 
%This forces the second y-axis.
%The random point is offscale anyway
[haxes,hline1,hline2] = plotyy(1,80,1,180);

ylabel(haxes(1),'Conductance (nS)','FontSize', 16) % label left y-axis
ylabel(haxes(2),'Diameter (nm)','FontSize', 16) % label right y-axis
xlabel(haxes(2),'Pulse Number','FontSize', 16) % label x-axis

%set(haxes(1),'Xlim',[0,22],'Ylim',[0 65],'YTick',[0:10:60]);
set(haxes(1),'Ylim',[0 65],'YTick',[0:10:60]);

for i = 1:6
    Dticks(i) = Gcalc(i,thickness);
end
%set(haxes(2),'Xlim',[0,22],'Ylim',[0 65],'YTick',Dticks,'YTickLabel',[1:1:6]);
set(haxes(2),'YTick',Dticks,'Ylim',[0 65],'YTickLabel',[1:1:6]);

grid(haxes(2),'on');



%gets rid of tick marks on right side from cond scale
set(gca,'box','off')
hold off;


%old electrical pulse D
%{
old electrical pulse fab

hf = findobj('Name','Electrical Pulse Fabrication - Diameter');
    if isempty(hf)
        hf = figure('Name','Electrical Pulse Fabrication - Diameter','NumberTitle','off');
    end
figure(hf);   
othermap = colormap(lines(7));
cmap = colormap(hot(10));

hold on;

plot(real(D),'k-');
markersize = 15;


    %set(colorbar,'YTick',[1:1:6])
for i = 2:length(D)
    line([i-1, i],[D(i-1),D(i)],'color',cmap(floor(abs(voltage(i))),:,:),'linewidth',3);
    
    line([i,i],[real(bquartD(i)), real(tquartD(i))],'color','black','linewidth',1);

    scatter(i-1,D(i-1),markersize,'MarkerFaceColor','black',...
        'MarkerEdgeColor','black','linewidth',1);

end
    fin = length(D);
    line([fin,fin],[bquartD(fin), tquartD(fin)],'color','black','linewidth',1);

    scatter(fin,real(D(fin)),markersize,'MarkerFaceColor','black',...
        'MarkerEdgeColor','black','linewidth',1);


colorbar('YTickLabel',...
    {'1 V','2 V','3 V','4 V',...
     '5 V','6 V','7 V','8 V','9 V','10V'})
%axis([0 60 0 7]);
xlabel ('Pulse Number','FontSize', 20);
ylabel ('Pore Diameter (nm)','FontSize', 20);

%set grid lines
grid on;
axh = gca;
set(axh,'XTick',[]);
set(axh,'YTick',[0:1:8]);


hold off;

%}



 
