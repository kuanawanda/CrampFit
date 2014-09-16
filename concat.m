function AKconcat(DNAevents,numplot);

si = 2e-6;


if numplot < 0;
    numplot = length(DNAevents)
end

%ymin= 10;
%ymax=20;


set(gca,'fontsize',20)

for i = 1:numplot:length(DNAevents)
    concat = [];
    for j = 1:numplot
        eventdata=DNAevents(i+j-1).data;
        baseline=DNAevents(i+j-1).baseline;
        concat = [concat; eventdata-baseline];
    end
    t = si*1:length(concat);


    plot(t,concat,'r');
    xlabel ('Time (us)','FontSize', 20);
ylabel ('Current (nA)','FontSize', 20);
title ('Concatenated Events - ssDNA','FontSize', 20);
ylim([-3 1]);    
pause;
end


