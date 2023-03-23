
%setup figure size/position in pixels
figure(1, 'position',[20,1000,2000,1600]);
clf;

[water mort lgndRD] = readPlotData();

% set various times
tMax = max([water.t(end) mort.t(end)]);

% plot range
tPlot     = [datenum([2020  2  1]) tMax];

objective_function = @ (p) v2c(p, water, mort);
v = [5 90 150 350 410 600 700 900]';
objective_function(v);

T_init = 10;
T_min = 1;
mu_T = 1.01;
iters_fixed_T = 10;
max_rand_step = v*0 + 5;

opts = optimset();
opts = optimset(opts, "lbound", v*0);
opts = optimset(opts, "ubound", v*0 + 1000);
opts = optimset(opts, "MaxIter", 10);
opts = optimset(opts, "Algorithm", "siman");
opts = optimset(opts, "T_init", T_init);
opts = optimset(opts, "T_min", T_min);
opts = optimset(opts, "mu_T", mu_T);
opts = optimset(opts, "iters_fixed_T", iters_fixed_T);
opts = optimset(opts, "max_rand_step", max_rand_step);
opts = optimset(opts, "trace_steps", true);

[p, objf, cvg, outp] = nonlin_min (objective_function, v, opts)
 subplot(2,1,2);
 p
 objf
 outp
 x = (outp.trace(:, 1) - 1) * iters_fixed_T + outp.trace(:, 2);
 x(1) = 0;
 outp.trace(:, 3) = outp.trace(:, 3) - 700;
 plot (x, cat (2, outp.trace(:, 3:end), T_init ./ (mu_T .^ outp.trace(:, 1))))
 legend ({"objective function value", "p(1)", "p(2)", "Temperature"})
 xlabel ("subiteration")
 grid on;
