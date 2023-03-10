function [water] = readPlotWastewaterCSV(fname, fips)

% file contents (as of March 1, 2023):
% sometimes the first column (line number) is absent

% ,sampling_week,effective_concentration_rolling_average,region,state,name,fipscode
% 0,2020-01-15,0.0,Northeast,MA,"Suffolk County, MA",25025
% 1,2020-01-22,0.0,Northeast,MA,"Suffolk County, MA",25025
% 2,2020-01-29,0.0,Northeast,MA,"Suffolk County, MA",25025
% 3,2020-02-05,0.0,Northeast,MA,"Suffolk County, MA",25025
% 4,2020-02-12,0.0,Northeast,MA,"Suffolk County, MA",25025
% 5,2020-02-19,0.0,West,CA,"San Luis Obispo County, CA",6079
% 6,2020-02-19,0.0,Northeast,MA,"Suffolk County, MA",25025
% 7,2020-02-26,0.0,Northeast,MA,"Suffolk County, MA",25025
% 8,2020-03-04,1.4501821146335496,Northeast,MA,"Suffolk County, MA",25025
% 9,2020-03-11,12.590344274524805,Northeast,MA,"Suffolk County, MA",25025
% ...

t = [];
n = [];

% read csv
cells = csv2cell(fname, 1);

%filter by fips
fips1 = cell2mat(cells(:,end));
cells = cells(find(fips1 == fips),:);
name = cells(1,end-1){1};

% convert date
t = cellfun(@(c) datenum(c, 'yyyy-mm-dd'), cells(:,end-5));
n = cell2mat(cells(:,end-4));

%interpolate
water.t = t(1):t(end);
water.n = interp1(t, n, water.t);

% plot with vertical log scale
% take care of zeros by showing them at the lower limit
i0 = find(n == 0);
n(i0) = 0.1;

semilogy(t, n, '-bo');
ylim([0.1 1e4]);
ylbl = get (gca, 'yticklabel');
ylbl{1} = '0';
set (gca, 'yticklabel', ylbl);
datetick('x');
legend(sprintf('Wastewater %s', name), 'Location', 'NorthEast');
ylabel('RNA concentration [counts/ml]');
grid on;
