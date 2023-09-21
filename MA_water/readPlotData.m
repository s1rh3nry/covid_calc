function [water mort lgndRD] = readPlotData()

% read and plot wastewater data
subplot(2,1,2);
fname = '../data/biobot/wastewater.csv';
[water] = readPlotWastewaterCSV(fname);

hold on
fname = '../data/MWRA/wastewater.txt';
[water2] = readPlotWastewaterTXT(fname);
hold off
legend({water.name, water2.name}, 'Location', 'SouthEast');

%splice
isplice = find(water2.t > water.t(end));
water.t = [water.t water2.t(isplice)];
water.n = [water.n water2.n(isplice)];

% read and plot reported deaths
subplot(2,1,1);
fname = '../data/MA/mortality.csv';
[mort lgndRD] = readPlotMortalityCSV(fname);

