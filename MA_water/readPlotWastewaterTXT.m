function [water] = readPlotWastewaterTXT(fname)

% Read messy data extracted from PDF table via e.g.
% pdftotext -table -f 16 -l 18 MWRAData20230918-data.pdf 20230918.txt
% sed -i 's/\f//g' 20230918.txt
%
% Clean data used to be available on github.  Now there is a less useful 
% CDC page with unitless numbers.  MWRA data still has units.  Is it normalized?
%
% Source:
% https://www.mwra.com/biobot/biobotdata.htm

name = 'MWRA Deer Island';
pos = [1 10;  14 20; 20 27;];
minL = 28;
maxL = 60;
tMin = 0*datenum([2023 4 1]);
tMax = 10*datenum([2023 5 1]);
targetCol = 18; % typical end of 1st reading

t = [];
n = [];

% read txt line by line
f = fopen(fname, 'rt');

if f <= 0
  error(sprintf('Could not open file %s', fname))
end

nlines = 1;
conc = [0 0];

while ~feof(f)
  s = fgetl(f);
  
  % long enough?
  if length(s) < minL
    length(s);
    continue;
  end

  % truncate
  if length(s) > maxL
    s = s(1:maxL);
  end
  
  % extract date
  try
    tstr = s(1:pos(1,2));
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
  
  % find start/end of number positions in string
  nums = [];
  for i = 2:length(s)
    if isdigit(s(i)) && isspace(s(i-1))
       nums = [nums; i 0];
    end
    
    if isdigit(s(i-1)) && isspace(s(i))
       nums(end,2) = i-1;
    end
  end
  
  if nums(end,2) == 0
    nums(end,2) = length(s);
  end
  
  % find number ending nearest to target position 
  % this is needed because column widths vary
  [m1 i1] = min(abs(nums(:,2)-targetCol));
  
  numbers = sscanf(s(nums(i1,1):end), ' %d');
  conc = numbers(1:2);

  if length(conc) == 2
    t(nlines) = tt;
    n(nlines) = mean(conc);
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
