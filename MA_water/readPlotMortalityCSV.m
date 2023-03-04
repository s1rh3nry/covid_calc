function [mort lgnd]=readPlotMortalityCSV(fname)

if exist(fname) != 2
  error(sprintf('No such file: %s', fname));
else
  printf('Read file: %s\n', fname);
end

% read and plot reported deaths

% read csv
cells = csv2cell(fname, 1);

% convert date
mort.t = cellfun(@(c) datenum(c, 'yyyy-mm-dd'), cells(:,1));
mort.n = cell2mat(cells(:,2));

% smooth
wnd = 7;
na = filter(ones(wnd,1)/wnd, 1, mort.n); %# moving average
ta = filter(ones(wnd,1)/wnd, 1, mort.t-mort.t(1)); %# moving average

hold on;
plot(ta+mort.t(1), na, '-', 'color', 0.7*[1 1 1], 'Linewidth', 7);
hold off;

grid on

xlabel('Date (month/day)');
lgnd = {'COVID-19 daily deaths (7 day avg.)'};
drawnow;
