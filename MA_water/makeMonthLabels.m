function makeMonthLabels(tMinPlot, tMaxPlot)
% customize x-axis labels
nMonths = round((tMaxPlot-tMinPlot)/365.25*12);
d = 1;
if nMonths > 15
  d = 2;
end

if nMonths > 24
  d = 3;
end


xtickMonths = 3:d:(nMonths+d);
xticks = [];

for i=1:length(xtickMonths)
  xticks(i) = datenum([2020 xtickMonths(i) 1]);
  xtickLbl{i} = datestr(xticks(i), 'mmm-yyyy');
end

for i=1:2
  subplot(2,1,i)
  xlim([tMinPlot tMaxPlot])
  set (gca, 'xtick', xticks);
  set (gca, 'xticklabel', xtickLbl);
  xlabel('Date (first day of month-year)');
end
