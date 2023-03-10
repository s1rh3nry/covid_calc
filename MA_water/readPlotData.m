function [water mort lgndRD] = readPlotData()

% read and plot wastewater data
subplot(2,1,2);
fname = '../data/biobot/wastewater.csv';
[water] = readPlotWastewaterCSV(fname);

% read and plot reported deaths
subplot(2,1,1);
fname = '../data/MA/mortality.csv';
[mort lgndRD] = readPlotMortalityCSV(fname);

