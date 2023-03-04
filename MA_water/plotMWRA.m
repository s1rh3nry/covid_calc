EXPORT_PLOT = 0; % set to one to export image

% set various times

% plot range
tPlot     = [datenum([2020  2  1]) datenum([2023  3  1])];

% Model fit start & end
H{1}.tFit = [tPlot(1)              datenum([2020  6  1])];
H{2}.tFit = [datenum([2020  9  1]) datenum([2021  3  1])];
H{3}.tFit = [datenum([2021  5  1]) datenum([2021 12 15])];
H{4}.tFit = [datenum([2022  1 21]) datenum([2022  4  1]) tPlot(2)];

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

guess = [0.1 15]; % a reasonable starting point

H{1}.tFit(1) = max([water.t(1) mort.t(1)]); % adjust start of H1 fit to data

% run fits and plot
lgndModels = {};
for i=1:length(H)  
  [t y H{i}.p H{i}.cor H{i}.cov ff] = fitMWRA(guess, mort, water, H{i}.tFit);
                                 
  plot(t,y,clr{i}, 'LineWidth', 5);
  drawnow;
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
    plot(t,y,[clr{i} ':'], 'LineWidth', 5);
    lgndModels{length(lgndModels)+1} = ...
       sprintf('Water-based model H%d (%s)', i, str);
  end
end

hold off;

printModelsTable(H);

% beautify graphs
legend([lgndRD lgndModels], 'Location', 'NorthEast');
title(sprintf('Association of MA COVID-19 mortality with viral RNA in wastewater'));
ylabel(sprintf('Daily deaths (see legend)'))
ylim([0 200])

makeMonthLabels(tPlot(1), tPlot(2));

if EXPORT_PLOT == 1
  % generate image file
  exportPlot("1", 2.5*[12 8])
end
