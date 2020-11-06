function [Coup, Couphist, Vres] = evalsmooth(direc)

resdir = dir(direc);
ndir = length(resdir) - 2;


% Load the first set of results to be able to check sizes
[c, v, s] = PatchData([direc filesep resdir(4).name filesep 'Mod.patch']);
coup = sign(s(:, 2)).*mag(s(:, 1:2), 2)./mag(s(:, 8:9), 2);
ressta = ReadStation([direc filesep resdir(4).name filesep 'Res.sta.data']);

% Make arrays
couprange = -2:.1:2;
Couphist = zeros(length(couprange), ndir); Couphist(:, 1) = hist(coup, couprange)';
Coup = zeros(size(v, 1), ndir); Coup(:, 1) = coup;
Vres = zeros(size(ressta.lon, 1), ndir); Vres(:, 1) = mag([ressta.eastVel, ressta.northVel], 2);

% Loop through and analyze
for i = 5:ndir
   [c, v, s] = PatchData([direc filesep resdir(i).name filesep 'Mod.patch']);
   coup = sign(s(:, 2)).*mag(s(:, 1:2), 2)./mag(s(:, 8:9), 2);
   ressta = ReadStation([direc filesep resdir(i).name filesep 'Res.sta.data']);
   Couphist(:, i-3) = hist(coup, couprange)';
   Coup(:, i-3) = coup;
   Vres(:, i-3) = mag([ressta.eastVel, ressta.northVel], 2);
end