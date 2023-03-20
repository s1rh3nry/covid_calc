EXPORT_PLOT = 1; % set to one to export image

%setup figure size/position in pixels
figure(1, 'position',[20,1000,2000,1600]);
clf;

[water mort lgndRD] = readPlotData();

% set various times
tMax = min([water.t(end) mort.t(end)]);

% plot range
tPlot     = [datenum([2020  3  1]) tMax];

daysPerModel = 100;
nmodel = floor(range(tPlot)/daysPerModel)

% Model fit start & end
H = {};
for i=1:nmodel
  H{i}.tFit = tPlot(1)+daysPerModel*[(i-1)  i];
end

H{1}.tFit(1) = max([water.t(1) mort.t(1)]); % adjust start of H1 fit to data
H{end}.tFit(2) = tMax;

%%% model mortality from water signal

% run fits and plot
hold on;
[H ratio meanTime lgndModels flag] = runPlotFits(H, water, mort);
hold off;

printModelsTable(H);

% beautify graphs
beautify(tPlot, tMax, [lgndRD lgndModels]);

subplot(2,1,2);
errorbar(meanTime, log10(ratio(:,1)), ratio(:,2)./ratio(:,1), '#~b.');

% highlight flagged points
iflag = find(flag == 1);
hold on;
errorbar(meanTime(iflag), log10(ratio(iflag,1)), ratio(iflag,2)./ratio(iflag,1), '#~r.x');
hold off;

ylim([-3 0]);
set (gca, 'ytick', [-3 -2 -1 0]);
set (gca, 'yticklabel', [0.001, 0.01 0.1 1]);
ylabel(sprintf('Deaths per wastewater RNA concentration'))

if EXPORT_PLOT == 1
  % generate image file
  exportPlot("2", 2.5*[12 8])
end
