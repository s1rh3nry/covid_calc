function exportPlot(name, papersize)

set(gcf, 'PaperSize', papersize);
set(gcf, 'PaperPosition', [0 0 papersize]);
print(gcf, sprintf("plots/%s.png", name));
  
