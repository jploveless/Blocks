function [fault, block, ratio, bstr2, bvols] = MonteCarloPotencyNoiseOnly(direc, n)
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

% Change to selected directory
curd = pwd;
cd(direc)
%
%% Load command file
%comn = dir('*_mc.command');
%comn = strtrim(comn.name);
%if isempty(comn)
%   comn = ls('*.command');
%   comn = strtrim(comn);
%   [p, f, e] = fileparts(comn);
%   keyboard
%   com = ReadCommand(comn);
%   if com.segFileName(1) ~= '/'    % Dealing with relative file names
%      % Adjust segment and block file names to reflect the fact that we're one directory down
%      com.segFileName = ['..' filesep com.segFileName];
%      com.blockFileName = ['..' filesep com.blockFileName];
%      com.reuseElasticFile = ['.' com.reuseElasticFile];
%   end
%   com.staFileName = 'Noisy.sta.data';
%   comn = [f '_mc' e];
%   WriteCommand(com, comn);
%end   

% Load station file
s = ReadStation('Mod.sta.data');
o = ReadStation('Obs.sta.data');
b = ReadBlock('Mod.block');
fault = NaN(length(b.interiorLon), n);
block = fault;
ratio = fault;
bstr2 = fault;
bvols = fault;

noisee = repmat(o.eastSig(:), 1, n).*randn(length(o.eastSig), n);
noisen = repmat(o.northSig(:), 1, n).*randn(length(o.northSig), n);

for i = 1:n
   S = s;
   S.eastVel = noisee(:, i);
   S.northVel = noisen(:, i);
   rn = GetRunName
   mkdir(rn)
   WriteStation([rn filesep 'Res.sta.data', S.lon, S.lat, S.eastVel, S.northVel, o.eastSig, o.northSig, S.corr, S.other1, S.tog, S.name);
   system(sprintf('cp Mod.segment %s/.', rn));
   system(sprintf('cp Mod.block %s/.', rn));
   resid2strain(newdir, {'rest_of_the_world', 'Indo_Austrailia', 'SouthEastAsia', 'BurmanRanges', 'Eurasia'});
   [potencyAllFaults, potencyBlock, potencyRatio, blockStrain2, blockVolume] = PotencyRatioDelaunay(newdir);
   fault(:, i) = potencyAllFaults(:);
   block(:, i) = potencyBlock(:);
   ratio(:, i) = potencyRatio(:);
   bstr2(:, i) = blockStrain2(:);
   bvols(:, i) = blockVolume(:);
end

% Move all directories into "mcpotency"
%!mkdir mcpotency


% Change back to original directory
cd(curd)