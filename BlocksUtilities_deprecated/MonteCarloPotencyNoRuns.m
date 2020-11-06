function [fault, block, ratio, bstr, bvols] = MonteCarloPotencyNoRuns(direc, n, str, exclud, int, ang)
% MONTECARLOPOTENCY  Tests sensitivity of potency calculation to noise perturbation.
%   MONTECARLOPOTENCY(DIREC, N) uses the contents of the results directory DIREC to 
%   carry out a Monte Carlo simulation of the potency's sensitivity to noise 
%   perturbations.  Gaussian noise is added to the velocity field in Mod.sta.data
%   and the model is re-inverted, with potency calculated after each of N runs.
%   The results of each model run are saved to a directory "mcpotency" within DIREC.
%
%   [FAULT, BLOCK, RATIO] = MONTECARLOPOTENCY(...) returns arrays of on-fault, 
%   off-fault, and ratio values for potency (FAULT, BLOCK, and RATIO), respectively,
%   of size (number of blocks)-by-N that can easily be averaged.
%

b = ReadBlock([direc filesep 'Mod.block']);
fault = NaN(length(b.interiorLon), n);
block = fault;
ratio = fault;
bstr2 = fault;
bvols = fault;

for i = 1:n
   dn = [direc filesep 'mcpotency/' sprintf('%010.0f', i)];
   if str == 1
      resid2strain(dn, exclud, int, ang);
   end
   [potencyAllFaults, potencyBlock, potencyRatio, blockStrain, blockVolume] = PotencyRatioDelaunay(dn);
   fault(:, i) = potencyAllFaults(:);
   block(:, i) = potencyBlock(:);
   ratio(:, i) = potencyRatio(:);
   bstr(:, i) = blockStrain(:);
   bvols(:, i) = blockVolume(:);
end

save([direc filesep sprintf('mcpotency1-%g.mat', n)], 'fault', 'block', 'ratio', 'bstr', 'bvols')