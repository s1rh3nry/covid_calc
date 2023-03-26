function beautify(tPlot, tMax, lgnd)
% customize x-axis labels
nMonths = round((tPlot(2)-tPlot(1))/365.25*12);
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
  xlim([tPlot(1) tPlot(2)])
  set (gca, 'xtick', xticks);
  set (gca, 'xticklabel', xtickLbl);
  xlabel('Date (first day of month-year)');
end

subplot(2,1,1)
if nargin > 2
  legend(lgnd, 'Location', 'NorthEast');
end
title(sprintf('Association of MA COVID-19 mortality with viral RNA in wastewater (through %s)', ...
              datestr(tMax)));
ylabel(sprintf('Daily deaths (see legend)'))
ylim([0 200])
