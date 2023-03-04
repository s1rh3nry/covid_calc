function yFit=waterMortality(p, yWater, tWater, tFit, offset)

ratio = p(1);
pole = 1/p(2); 

% linear model to produce mortality output from water measurements
% yWater (values) and tWater (times)
ySim = lsim(tf([0 ratio*pole], [1 pole]), yWater, tWater);

%interpolate onto desired times (tFit) and add offset
yFit = offset + interp1(tWater-tWater(1), ySim, tFit-tWater(1));
