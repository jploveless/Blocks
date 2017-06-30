function [fault, block, ratio, bstr2, bvols] = MonteCarloPotencyNoRunsStrain(direc, n)
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
%   [potencyAllFaults, potencyBlock, potencyRatio, blockStrain2, blockVolume] = PotencyRatioDelaunay(dn);
%   fault(:, i) = potencyAllFaults(:);
%   block(:, i) = potencyBlock(:);
%   ratio(:, i) = potencyRatio(:);
%   bvols(:, i) = blockVolume(:);
   sb = ReadBlock([dn filesep 'Strain.block']);
   smag = sqrt(0.5*sum([sb.other1.^2, 2*sb.other2.^2, sb.other3.^2], 2));
   bstr2(:, i) = smag;
end

save([direc filesep sprintf('mcpotency1-%g.mat', n)], 'bstr2', '-append')