function [water mort lgndRD] = readPlotData()

% read and plot wastewater data
subplot(2,1,2);
fname = '../data/biobot/wastewater_by_county.csv';
fips = 25025; % location code for Suffolk County, MA (Boston area)
[water] = readPlotWastewaterCSV(fname, fips);

% read and plot reported deaths
subplot(2,1,1);
fname = '../data/MA/mortality.csv';
[mort lgndRD] = readPlotMortalityCSV(fname);

