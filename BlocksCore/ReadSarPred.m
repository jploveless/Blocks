function Sar = ReadSarPred(sarfile)
% ReadSarPred  Reads a SAR results file.
%   SAR = ReadSarPred(SARFILE) reads the textfile SARFILE, which is written 
%   by WriteSarResults.m.
%

s = load(sarfile);

if ~isempty(s)
   Sar = struct('lon', s(:, 1), 'lat', s(:, 2), 'Obs', s(:, 3), 'Mod', s(:, 4), 'Resid', s(:, 5), 'Def', s(:, 6), 'Rot', s(:, 7), 'Ramp', s(:, 8), 'Shift', s(:, 9), 'Tri', s(:, 10), 'Strain', s(:, 11));
else
   zv = zeros(0, 1);
   Sar = struct('lon', zv, 'lat', zv, 'Obs', zv, 'Mod', zv, 'Resid', zv, 'Def', zv, 'Rot', zv, 'Ramp', zv, 'Shift', zv, 'Tri', zv, 'Strain', zv);
end