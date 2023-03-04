function [mort lgnd]=readPlotMortality(fname)

if exist(fname) != 2
  error(sprintf('No such file: %s', fname));
else
  printf('Read file: %s\n', fname);
end

% read and plot reported deaths
data = xlsread(fname, 12);
data(:,1) += datenum([1900 1 1]) -2;  % adjust time to Octave offset

mort.t = data(:,1)'; % times
mort.n = data(:,2)'; % counts

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
