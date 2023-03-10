EXPORT_PLOT = 0; % set to one to export image

%setup figure size/position in pixels
figure(1, 'position',[20,1000,2000,1600]);
clf;

[water mort lgndRD] = readPlotData();

% set various times
tMax = max([water.t(end) mort.t(end)]);

% plot range
tPlot     = [datenum([2020  2  1]) tMax];

% Model fit start & end
H{1}.tFit = [tPlot(1)              datenum([2020  6  1])];
H{2}.tFit = [datenum([2020  9  1]) datenum([2021  3  1])];
H{3}.tFit = [datenum([2021  5  1]) datenum([2021 12 15])];
H{4}.tFit = [datenum([2022  1 21]) datenum([2022  4  1]) tPlot(2)];

H{1}.tFit(1) = max([water.t(1) mort.t(1)]); % adjust start of H1 fit to data

%%% model mortality from water signal

% run fits and plot
hold on;
[H ratio meanTime lgndModels] = runPlotFits(H, water, mort);
hold off;

printModelsTable(H);

% beautify graphs
legend([lgndRD lgndModels], 'Location', 'NorthEast');
title(sprintf('Association of MA COVID-19 mortality with viral RNA in wastewater (through %s)', ...
              datestr(tMax)));
ylabel(sprintf('Daily deaths (see legend)'))
ylim([0 200])

makeMonthLabels(tPlot(1), tPlot(2));

if EXPORT_PLOT == 1
  % generate image file
  exportPlot("1", 2.5*[12 8])
end
