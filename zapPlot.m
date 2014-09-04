function zapPlot(zapData);

voltage_select = -5;

bias = .1; %100mV

for i = 1:length(zapData)-1
    all_deltG(i) = zapData(i).deltG;
    all_deltD(i) = zapData(i).deltD;
    voltage(i) = zapData(i).voltage;
    G(i) = zapData(i).avgI;
    D(i) = zapData(i).avgD;
    tquartI(i) = zapData(i).tquartI;
    tquartD(i) = zapData(i).tquartD;
    bquartI(i) = zapData(i).bquartI;
    bquartD(i) = zapData(i).bquartD;
end

i = length(zapData);
    G(i) = zapData(i).avgI;
    D(i) = zapData(i).avgD;
    tquartI(i) = zapData(i).tquartI;
    tquartD(i) = zapData(i).tquartD;
    bquartI(i) = zapData(i).bquartI;
    bquartD(i) = zapData(i).bquartD;
    
deltG = all_deltG(voltage == voltage_select);

hf = findobj('Name','Electrical Pulse Histogram - Conductance');
    if isempty(hf)
        hf = figure('Name','Electrical Pulse Histogram - Conductance','NumberTitle','off');
    end
figure(hf);    
Gstep = -10:1:10;
hist(deltG,Gstep);
xlabel ('Change in Conductance (nS)','FontSize', 20);
ylabel ('Number of Pulses','FontSize', 20);

deltD = all_deltD(voltage == voltage_select);

hf = findobj('Name','Electrical Pulse Histogram - Diameter');
    if isempty(hf)
        hf = figure('Name','Electrical Pulse Histogram - Diameter','NumberTitle','off');
    end
figure(hf);    
Dstep = -1:.1:1;
hist(deltD,Dstep);
set(get(gca,'child'),'FaceColor',[.7 .7 .7],'EdgeColor','k');
set(gca,'Ylim',[0 max(histc(deltD, Dstep))+1]); 
xlabel ('Change in Diameter (nm)','FontSize', 20);
ylabel ('Number of Pulses','FontSize', 20);


hf = findobj('Name','Electrical Pulse Fabrication - Diameter');
    if isempty(hf)
        hf = figure('Name','Electrical Pulse Fabrication - Diameter','NumberTitle','off');
    end
figure(hf);   
cmap = colormap(jet(10));

hold on;
for i = 1:length(D)-1
    line([i,i],[bquartD(i), tquartD(i)],'color','black','linewidth',1);
    scatter(i,D(i),'MarkerFaceColor',cmap(floor(abs(voltage(i))),:,:),...
        'MarkerEdgeColor','black','linewidth',1);
end

i = length(D);
    line([i,i],[bquartD(i), tquartD(i)],'color','black','linewidth',1);
    scatter(i,D(i),'MarkerFaceColor',[.7 .7 .7],...
        'MarkerEdgeColor','black','linewidth',1);

    %set(colorbar,'YTick',[1:1:6])
colorbar('YTickLabel',...
    {'1 V','2 V','3 V','4 V',...
     '5 V','6 V','7 V','8 V','9 V','10V'})
xlabel ('Pulse Number','FontSize', 20);
ylabel ('Pore Diameter (nm)','FontSize', 20);
grid on;
axh = gca;
set(axh,'XTick',[]);
set(axh,'YTick',[0:1:5]);
hold off;

 
