function [water] = readPlotWastewaterTXT(fname)

% Read messy data extracted from PDF table via e.g.
% pdftotext -layout -f 3 MWRAData20230918-data.pdf 20230918.txt
% sed -i 's/\f//g' 20230918.txt       # strip FF char
% sed -i "s/^[ \t]*//" 20230918.txt   # strip leading spaces
% 
% This results in not-quite-fixed-width text data.
%
% Clean data used to be available on github.  Now there is a less useful 
% CDC page with unitless numbers.  MWRA data still has units and matches earlier 
% Biobot data.
%
% Source:
% https://www.mwra.com/biobot/biobotdata.htm

name = 'MWRA Deer Island';

% min/max line length
minL = 28;
maxL = 60;

% filter time for debugging
tMin = 0*datenum([2023 4 1]);
tMax = 10*datenum([2023 5 1]);

targetCol = 21; % typical end pos of 1st value
dateWidth = 10;
h = []; % for histogram

t = [];
n = [];

% read txt line by line
f = fopen(fname, 'rt');

if f <= 0
  error(sprintf('Could not open file %s', fname))
end

nlines = 1;

while ~feof(f)
  s = fgetl(f);
  
  % long enough?
  if length(s) < minL
    continue;
  end

  % truncate
  if length(s) > maxL
    s = s(1:maxL);
  end
  
  % extract date
  try
    tstr = s(1:dateWidth);
    tt = datenum(tstr);
    if tt < tMin || tt > tMax
      continue
    end
  catch
    continue
  end
  
  %printf('%s\n', s);
  
  %remove leading date string
  sp = strfind(s, ' ');
  s = s(sp(1):end);
  
  % find start/end pos of number fields in string
  nums = [];
  for i = 2:length(s)
    if isdigit(s(i)) && isspace(s(i-1)) %start
       nums = [nums; i 0];
    end
    
    if isdigit(s(i-1)) && isspace(s(i)) %end
       nums(end,2) = i-1;
    end
  end
  
  if nums(end,2) == 0 %add final end
    nums(end,2) = length(s);
  end
  
  % find number ending nearest to target position 
  % this is needed because column widths vary
  [m1 i1] = min(abs(nums(:,2)-targetCol));
  
  h = [h nums(i1,2)]; % for stats/histogram
  
  % convert numbers in string, beginning with nearest-to-target
  numbers = sscanf(s(nums(i1,1):end), ' %d');

  if m1 >= 4
    printf('%s %s -- deviation = %d\n', tstr, s, m1);
    numbers'
  end
  
  if length(numbers) >= 2
    t(nlines) = tt;
    n(nlines) = mean(numbers(1:2));
    nlines += 1;
  end
end

fclose(f);

%interpolate to daily grid
water.t = t(1):t(end);
water.n = interp1(t, n, water.t);
water.name = name;

% plot with vertical log scale
% take care of zeros by showing them at the lower limit
i0 = find(n == 0);
n(i0) = 0.1;

semilogy(t, n, '-r.');
ylim([0.1 1e4]);
ylbl = get (gca, 'yticklabel');
ylbl{1} = '0';
set (gca, 'yticklabel', ylbl);
datetick('x');
title('Boston-area wastewater SARS-CoV-2 RNA concentration');
legend(sprintf('%s', name), 'Location', 'SouthEast');
ylabel('RNA concentration [counts/ml]');
grid on;

% print stats
mid = (min(h)+max(h))/2;
unc = (max(h)-min(h))/2;

printf('%d number positions (%d days)\n mean=%.2f, median=%d, %.1f +/- %.1f [%d...%d]\n', ...
        length(h), length(water.t), mean(h), median(h), mid, unc, min(h), max(h))
%return

%for code development: plot histogram of number positions
clf;
bar(hist(h, 1:30));

