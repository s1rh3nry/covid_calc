function [H, ratio, meanTime, lgnd, flag]=runPlotFits(H, water, mort)

lgnd = {};
ratio    = zeros(length(H),2);
meanTime = zeros(length(H),1);
flag     = zeros(length(H),1);

clr = {'c', 'r', 'g', 'm', 'b'};

guess = [0.1 10]; % a reasonable starting point for fit params

for i=1:length(H)  
  H{i}.tFit(2) = min([H{i}.tFit(2) mort.t(end)]);
  [t y H{i}.p H{i}.cor H{i}.cov ff] = fitMWRA(guess, mort, water, H{i}.tFit);
  ratio(i,1) = H{i}.p(1);
  ratio(i,2) = sqrt(H{i}.cov(1,1));
  meanTime(i) = mean(H{i}.tFit(1:2));
  
  %adjust linestyle & comment based on plausibility
  ls = '-';
  comment = '';
  if (H{i}.p(2) - 2 * sqrt(H{i}.cov(2,2))) > 100 % delay too long
    ls = '--';
    comment = ' - excessive delay';
    flag(i) = 1;
  end
  
  j = 1 + mod(i-1, length(clr));
  plot(t,y,[clr{j} ls], 'LineWidth', 5);
  drawnow;
  rh = ratio(i,1)+2*ratio(i,2);
  rl = ratio(i,1)-2*ratio(i,2);
  str2 = sprintf('%.4f deaths per wastewater RNA conc. 95%% CI: [%.4f, %.4f]', ...
                 H{i}.p(1), rl, rh);
  
  lgnd{length(lgnd)+1} = sprintf('Single-pole model H%d (fit)%s, %s', ...
                                 i, comment, str2);
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
    plot(t,y,[clr{j} ':'], 'LineWidth', 5);
    lgnd{length(lgnd)+1} = ...
       sprintf('Single-pole model H%d (%s), %s', ...
               i, str);
  end
end
