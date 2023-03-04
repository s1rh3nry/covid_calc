function printModelsTable(H)

% print fit ratio & delay with uncertainty
printf('\n\n');
fmt = '|%6s|%11s|%11s|%23s|%17s|\n';
printf(fmt, 'Model', 'From', 'To', 'Deaths per RNA/ml', ...
            'Delay (days)');
printf(strrep(sprintf(fmt, ' ', ' ', ' ', ' ', ' '), ' ', '-'));

for i=1:length(H)
   h = H{i};
   
   r = h.p(1);
   r_unc = sqrt(h.cov(1,1));
   d = h.p(2);
   d_unc = sqrt(h.cov(2,2)); 
   printf('|    H%d|%9s|%9s|%6.3f [%6.4f, %6.4f]|%4.1f [%4.1f, %4.1f]|\n', ...
          i, datestr(h.tFit(1)), datestr(h.tFit(2)), ...
          r, r-2*r_unc, r+2*r_unc, ...
          d, d-2*d_unc, d+2*d_unc);
end
