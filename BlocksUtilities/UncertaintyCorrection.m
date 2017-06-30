function cres = UncertaintyCorrection(direc)
% UNCERTAINTYCORRECTION  Corrects residual velocities by observed uncertainties.
%   UNCERTAINTYCORRECTION(DIREC) uses the Obs.sta.data and Res.sta.data files within
%   the directory DIREC to generate a "corrected" residual velocity field, Cres.sta.data.
%   The corrected field represents the original residual field, with velocity components
%   reduced by the reported station uncertainty in order to minimize residual speed.
%

% Read original fields
obs = ReadStation([direc 'Obs.sta.data']);
res = ReadStation([direc 'Res.sta.data']);

% Copy residual field
cres = res;

% Extract sign and magnitude of velocity components
sre = sign(res.eastVel);
srn = sign(res.northVel);

mre = abs(res.eastVel);
mrn = abs(res.northVel);

moe = obs.eastSig;
mon = obs.northSig;

% Compare residual field with observed uncertainties
de = mre - moe;
dn = mrn - mon;

corre = de;
corre(de <  0) = 0;
corrn = dn;
corrn(dn <  0) = 0;

cres.eastVel = sre.*corre;
cres.northVel = srn.*corrn;

WriteStation([direc 'Cres.sta.data'], cres.lon, cres.lat, cres.eastVel, cres.northVel, cres.eastSig, cres.northSig, cres.corr, cres.other1, cres.tog, cres.name)