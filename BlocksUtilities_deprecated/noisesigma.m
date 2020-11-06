function noisesigma(direc)
% NOISESIGMA(DIREC) compares noise estimation vs. reported uncertainties

r = ReadStation([direc filesep 'Strain.sta.data']);
s = ReadStation([direc filesep 'Obs.sta.data']);

sm = mag([s.eastSig s.northSig], 2);
rm = mag([r.eastVel, r.northVel], 2);

[s67, s95] = boxwhisker(sm);
[r67, r95] = boxwhisker(rm);

plotboxwhiskers([s67, r67], [s95, r95]);