function [cost]=v2c(v, water, mort, NOPLOT)

v = round(v);

% cost factors
% item 1 - (for gap) constant penalty / day
%          Try to cover all days, even when few deaths.
%
% item 2 - (for gap) additional penalty per (daily deaths)^2
%          Peaks are most important to cover.
%
costFactor = [10 0.05];

% Model fit start & end
global guesses = [];
global vOld = [];

v2 = reshape(v, 2, [])'

if length(vOld) == 0
  vOld = 0 * v2
end

different = sum(v2 ~= vOld, 2)'
keep = 0*different;
keep(find(different == 0)) = 1;
vOld = v2;
	  
H = {};
t0 = max([water.t(1) mort.t(1)]); % adjust start of H1 fit to data

N = length(v)/2;

% gap costs
costGaps = 0;

if v(1) > 0
  i0 = 1;
  i1 = v(1)+1;
  costGaps += (i1-i0)*costFactor(1) + sum(mort.n(i0:i1).^2)*costFactor(2);
end

if size(guesses, 1) ~= N
  guesses = repmat([0.1 10], N, 1);
  
  for i=1:N
    H{i}.needFit = 1;
  end
end

for i=1:N
  H{i}.needFit = 1 - keep(i); 

  if max(abs(guesses(i,:))) > 100
    guesses(i, :) = [0.1 10];
    H{i}.needFit = 1;
  end
  
  if NOPLOT==0
    H{i}.needFit = 1;
  end
end

guesses

for i=1:N
  t0 = mort.t(1) + v(2*i-1);
  t1 = mort.t(1) + v(2*i);
  
  H{i}.tFit = [t0 t1];
  H{i}.p = guesses(i,:);
  printf("H{%d}.needFit = %d\n", i, H{i}.needFit);
  
  if i < N
    t2 = mort.t(1) + v(2*i+1);
  else
    t2 = mort.t(1) + range(mort.t);
  end
  
  i0 = find(mort.t == t1);
  i1 = find(mort.t == t2);
  printf('gap from %6d to %6d\n', i0, i1);
  
  if i1 > i0+1
    costGaps += (i1-i0-1)*costFactor(1) + sum(mort.n(i0:i1).^2)*costFactor(2);
  end
end

%%% model mortality from water signal

% run fits and plot
hold on;
[H ratio meanTime lgndModels] = runPlotFits(H, water, mort, NOPLOT);
hold off;

cost = costGaps;

for i = 1:length(H)
  guesses(i,:) = H{i}.p;
  
  i0 = find(mort.t == H{i}.tFit(1));
  i1 = find(mort.t == H{i}.tFit(2));
  
  delta = H{i}.y' - mort.n(i0:i1);
  cost += sum(delta.^2);
end

printf('cost: %9.3f,   gaps: %9.3f,   fits: %9.3f\n', ...
       cost, costGaps, cost-costGaps);
       
if NOPLOT == 0
  tMax = max([water.t(end) mort.t(end)]);
  tPlot     = [datenum([2020  2  1]) tMax];
  beautify(tPlot, tMax);
  printModelsTable(H);
end
