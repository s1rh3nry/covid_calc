function [params CORP COVP fitfunc] = fitMWRA(guess, mort, water, tFit)

% Perform least-squares fitting of model parameters.
% The goal is to reproduce mortality data (mort) 
% by running wastewater RNA counts (water) through the model.
% Start and end times are in tFit.

i0 = find(mort.t == tFit(1));
i1 = find(mort.t == tFit(2));

% target output for model
t = mort.t(i0:i1);
y = mort.n(i0:i1);

% input: water data up to end of fit period
i1 = find(water.t == tFit(2));

nWater = water.n;
tWater = water.t;

% param 1: ratio (mortality per RNA concentration)
% param 2: time lag
fitfunc = @(t, p) (waterMortality(p, nWater, tWater, t, 0));

% run the fit. adjust params to make output match y
[F, params, CVG, ITER, CORP, COVP, COVR, STDRESID, Z, R2] = ...
                leasqr(t, y, guess, fitfunc);

% show correlation and covariance matrix
CORP;
COVP;

% show model system
tf([0 params(1)/params(2)], [1 1/params(2)]);

