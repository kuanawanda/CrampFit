function AKplot(DNAevents);

for i = 1:length(DNAevents)
    eventdepth(i)=DNAevents(i).blockage;
    eventlength(i)=DNAevents(i).length'*1e6;
    baseline(i)=DNAevents(i).baseline;
    x=cat(2,eventdepth',eventlength');
end
    
b_start=20;
b_end=26;
I_start=0; %start of current blocl
I_end=4; %end of current
t_start=0; %time
t_end=1000;
b_points=25;
t_points=25;% number of time cells
I_points=25; % number of blockage cells


b_step=linspace(b_start, b_end, b_points+1);
b_step_shift=linspace(b_start, b_end, b_points+1)+(b_end-b_start)/b_points/2;;
I_step=linspace(I_start, I_end, I_points+1);
I_step_shift=linspace(I_start, I_end, I_points+1)+(I_end-I_start)/I_points/2;
t_step=linspace(t_start, t_end, t_points+1);
t_step_shift=linspace(t_start, t_end, t_points+1)+(t_end-t_start)/t_points/2;
imaa=hist3(x,'Edges', {I_step, t_step});

set(gca,'fontsize',20)

set(0,'defaulttextinterpreter','tex');
set(0, 'DefaultFigureRenderer', 'Painters'); % I think the default renderer doesn't work well with .eps conversions
set(0,'DefaultAxesFontSize',16) 

%{
figure;hist(baseline,b_step_shift);
xlabel ('Baseline (nA)','FontSize', 20);
ylabel ('Number of Events','FontSize', 20);
title ('Baseline Histogram','FontSize', 20);
xlim([b_start b_end*1]);
%}

%{
figure;plot(baseline,eventdepth,'bo');
xlabel ('Baseline (nA)','FontSize', 20);
ylabel ('Event Depth (nA)','FontSize', 20);
title ('Depth vs Baseline','FontSize', 20);
xlim([b_start b_end*1]);
ylim([I_start I_end*1]);
%}

%%
hf = findobj('Name','DNA event plots');
    if isempty(hf)
        hf = figure('Name','DNA event plots','NumberTitle','off');
    end
    
figure(hf);

subplot(3,3,[4,5,7,8]);
pcolor(t_step,I_step,imaa);
shading('flat');
colormap('gray');
%colorbar('vert');
axis ('square');
xlabel ('Event duration (\mus)','FontSize', 20);
ylabel ('Current blockage (nA)','FontSize', 20);
%title ('Probablility density (pC^{-1})','FontSize', 20);
%xlim([t_start t_end*1.0]);
%ylim([I_start I_end*1.0]);

hist_axis = gca;
hist_axis_ratio = get(hist_axis,'PlotBoxAspectRatio');



subplot(3,3,[1,2]);
hist(eventlength,t_step_shift);
%xlabel ('Event duration (\mus)','FontSize', 20);
ylabel ('# of Events','FontSize', 20);
%title ('Duration Histogram','FontSize', 20);
xlim([t_start t_end*1]);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
top_axis = gca;
set(gca,'XTickLabel',{});


subplot(3,3,[6,9]);
[counts,bins] = hist(eventdepth,I_step_shift);
barh(bins, counts);
%ylabel ('Current blockage (nA)','FontSize', 20);
xlabel ('# of Events','FontSize', 20);
%title ('Blockage Histogram','FontSize', 20);
ylim([I_start I_end*1]);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
right_axis = gca;
set(gca,'YTickLabel',{});



%adjust ratios;

top_axis_ratio = hist_axis_ratio;
top_axis_ratio(2) = hist_axis_ratio(2)/2.4;
set(top_axis,'PlotBoxAspectRatio',top_axis_ratio);

right_axis_ratio = hist_axis_ratio;
right_axis_ratio(1) = hist_axis_ratio(1)/2.4;
set(right_axis,'PlotBoxAspectRatio',right_axis_ratio);



avgDepth = mean(eventdepth);
stdDepth = std(eventdepth);
avgLength = mean(eventlength);
stdLength = std(eventlength);

pm = setstr(177);
disp(['Depth: ' num2str(avgDepth) pm num2str(stdDepth) 'nA']);
disp(['Length: ' num2str(avgLength) pm num2str(stdLength) 'us'])


