function [H, ratio, meanTime, lgnd, flag]=runPlotFits(H, water, mort, NOPLOT)

if nargin < 4
  NOPLOT = 0;
end

lgnd = {};
ratio    = zeros(length(H),2);
meanTime = zeros(length(H),1);
flag     = zeros(length(H),1);

clr = {'c', 'r', 'g', 'm', 'b'};

if NOPLOT == 0
	% smooth
	wnd = 7;
	na = filter(ones(wnd,1)/wnd, 1, mort.n); %# moving average
	ta = filter(ones(wnd,1)/wnd, 1, mort.t-mort.t(1)); %# moving average

	subplot(2,1,1, "replace");
	hold off;
	plot(ta+mort.t(1), na, '-', 'color', 0.7*[1 1 1], 'Linewidth', 7);
	hold on;
end

for i=1:length(H)  
  H{i}.tFit(2) = min([H{i}.tFit(2) mort.t(end)]);
  
  if H{i}.needFit
    % fit the model
    printf('Fit H{%d}\n', i);
    [H{i}.p H{i}.cor H{i}.cov ff] = fitMWRA(H{i}.p, mort, water, H{i}.tFit);
    H{i}.p
  end
  
  % run the model
  H{i}.t = H{i}.tFit(1):H{i}.tFit(2);
  H{i}.y = waterMortality(H{i}.p, water.n, water.t, H{i}.t, 0);
  
  %adjust linestyle & comment based on plausibility
  ls = '-';
  comment = '';
  if H{i}.needFit
	  if (H{i}.p(2) - 2 * sqrt(H{i}.cov(2,2))) > 100 % delay too long
		ls = '--';
		comment = ' - excessive delay';
		flag(i) = 1;
	  end
  end
  
  if NOPLOT == 0  
	  j = 1 + mod(i-1, length(clr));
	  plot(H{i}.t,H{i}.y,[clr{j} ls], 'LineWidth', 3);
	  drawnow;
	  lgnd{length(lgnd)+1} = sprintf('Model H%d (fit)%s', i, comment);
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
		plot(t,y,[clr{j} ':'], 'LineWidth', 3);
		lgnd{length(lgnd)+1} = ...
		   sprintf('Model H%d (%s)', i, str);
	  end
  end
end

if NOPLOT == 0 
  hold off;
end
