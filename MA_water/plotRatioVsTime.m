EXPORT_PLOT = 1; % set to one to export image

% set various times

% plot range
tPlot     = [datenum([2020  3  1]) datenum([2023  2  21])];

daysPerModel = 100;
nmodel = ceil(range(tPlot)/daysPerModel)
% Model fit start & end
for i=1:nmodel
  H{i}.tFit = tPlot(1)+daysPerModel*[(i-1)  i];
end

H{end}.tFit(2) = tPlot(2);
%setup figure size/position in pixels
figure(1, 'position',[20,1000,2000,1600]);
clf;

[water mort lgndRD] = readPlotData();

%%% model mortality from water signal

% remove non-overlapping data at end
if water.t(end) < mort.t(end)
   d = mort.t(end) - water.t(end);
   mort.t = mort.t(1:(end-d));
   mort.n = mort.n(1:(end-d));
end

hold on;
clr = {'c', 'r', 'g', 'm', 'b'};

guess = [0.1 10]; % a reasonable starting point

H{1}.tFit(1) = max([water.t(1) mort.t(1)]); % adjust start of H1 fit to data

% run fits and plot
lgndModels = {};
times = [];
ratios = [];
ratiosL = [];
ratiosh = [];

for i=1:length(H)  
  H{i}.tFit(2) = min([H{i}.tFit(2) mort.t(end)]);
  [t y H{i}.p H{i}.cor H{i}.cov ff] = fitMWRA(guess, mort, water, H{i}.tFit);
  ratios(i) = H{i}.p(1);
  ratiosL(i) = sqrt(H{i}.cov(1,1));
  ratiosH(i) = sqrt(H{i}.cov(1,1));
  
  times(i) = mean(H{i}.tFit(1:2));
  j = 1 + mod(i-1, length(clr));
  plot(t,y,clr{j}, 'LineWidth', 5);
  lgndModels{length(lgndModels)+1} = sprintf('Water-based model H%d (fit)', i);
  % Allow forecast/hindcast.
  if length(H{i}.tFit) > 2
    if H{i}.tFit(3) > H{i}.tFit(2)
      t = H{i}.tFit(2):H{i}.tFit(3);
      str = 'forecast';
    else
      t = H{i}.tFit(3):H{i}.tFit(1);
      str = 'hindcast';
    end
    y = waterMortality(H{i}.p, water.n, water.t, t, 0);
    plot(t,y,[clr{j} ':'], 'LineWidth', 5);
    lgndModels{length(lgndModels)+1} = ...
       sprintf('Water-based model H%d (%s)', i, str);
  end
end

hold off;

subplot(2,1,2);
errorbar(times, log10(ratios), ratiosL./ratios, '#~b.');
ylim([-3 0]);

printModelsTable(H);

% beautify graphs
subplot(2,1,1);
legend([lgndRD lgndModels], 'Location', 'NorthEast');
title(sprintf('Association of MA COVID-19 mortality with viral RNA in wastewater'));
ylabel(sprintf('Daily deaths (see legend)'))
ylim([0 200])

makeMonthLabels(tPlot(1), tPlot(2));

if EXPORT_PLOT == 1
  % generate image file
  exportPlot("2", 2.5*[12 8])
end
