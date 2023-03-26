
%setup figure size/position in pixels
figure(1, 'position',[20,1000,1500,1000]);
clf;
figure(2, 'position',[1600,1000,1000,1000]);
clf;
figure(1);

[water mort lgndRD] = readPlotData();
tEnd = min([water.t(end) mort.t(end)]) - mort.t(1);

objective_function = @ (p) v2c(p, water, mort, 1);

vOld = [];

v00 = [0 69; 156 340; 345 646; 677 tEnd]
N = size(v00,1);
nplot = 2*N;
delta = -50:50;

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
	  % prevent overlap by adjusting adjacent period
	  if j==1 && r>1
	    v(r-1,2) = min([v(r-1,2) v(r,j)-1]);
	  end

	  if j==2 && r<N
	    v(r+1,1) = max([v(r+1,1) v(r,j)+1]);
	  end	  
	  
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

