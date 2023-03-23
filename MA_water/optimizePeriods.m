
%setup figure size/position in pixels
figure(1, 'position',[20,1000,1000,1000]);
clf;
figure(2, 'position',[1150,1000,1000,1000]);
clf;
figure(1);

[water mort lgndRD] = readPlotData();

% set various times
tMax = max([water.t(end) mort.t(end)]);

% plot range
tPlot     = [datenum([2020  2  1]) tMax];

objective_function = @ (p) v2c(p, water, mort, 1);

vOld = [];

v00 = [0 69; 156 332; 400 646; 677 1091]
N = size(v00,1);
nplot = 2*N;
delta = -25:50;

for r=1:N
for j=1:2
  c = 0*delta;
  cBest = 1e99;
  
  if (r==1 && j==1) || (r==N && j==2)
    continue;
  end
  
  for i = 1:length(delta)
    v = v00;
    v(r, j) += delta(i);
    v
	  
	  v = reshape(v', 1, [])
	  c(i) = objective_function(v);
	  
	  if c(i) < cBest
		cBest = c(i);
		vBest = v;
	  end
  end
  
    figure(2);
    subplot(N,2,(r-1)*2+j);
	plot(delta, c, '-bo');
	grid on;
	drawnow;

    figure(1);
	v2c(vBest, water, mort, 0);
	v00 = reshape(vBest, 2, [])'
	drawnow;
end
end
