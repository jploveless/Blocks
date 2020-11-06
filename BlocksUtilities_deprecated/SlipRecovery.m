function u = SlipRecovery(rdir, nTrials, p)
% SLIPRECOVERY runs multiple inversions to test the recovery of the triangular slip.
%   SLIPRECOVERY(RDIR, NTRIALS, FULL) uses the output block model results in directory 
%   RDIR as input to NTRIALS iterations of either a full block model run (FULL = 1), or
%   just a triangular inversion (FULL = 0).  If FULL = P, where P is the patch structure
%   used in the original inversion, RDIR/Tri.sta.data will be used as the base velocity 
%   file, and TRIINV will be called.  If FULL = '(command-file)', where '(command-file)'
%   is the name of a modified .command file whose specified station file is 
%   RDIR/Mod-noise.sta.data, then RDIR/Mod.sta.data will be modified with a random instance
%   of noise added for each iteration, and BLOCKS will be called.
%
%   Note: It is assumed that this function is run from the RESULTS master directory.
%

% Probably going to need info. from the command file, so read it in
comm = dir([rdir filesep '*.command']);
comm = ReadCommand(['..' filesep 'command' filesep comm.name]);

if isstruct(p)
   u = NaN(2*size(p.v, 1), nTrials);
   s = ReadStation([rdir filesep 'Tri.sta.data']);
   k = comm.reuseElasticFile;
   for i = 1:nTrials
      fprintf('\nWorking on trial %d of %d...', i, nTrials);
      u(:, i) = triinv(s, p, comm.triSmooth, k, 1, comm.triEdge);
   end

else

   for i = 1:nTrials
      fprintf('\nWorking on trial %d of %d...', i, nTrials);
      s = ReadStation([rdir filesep 'Mod.sta.data']);
      noise2 = sign(randn(numel(s.lon), 1)).*(1.5 + 0.5*randn(numel(s.lon), 1)) + 5e-4;
      noise1 = sign(randn(numel(s.lon), 1)).*(1.5 + 0.5*randn(numel(s.lon), 1)) + 5e-4;
      s.eastVel = s.eastVel + noise1;
      s.northVel = s.northVel + noise2;
      s.eastSig = abs(noise1);
      s.northSig = abs(noise2);
      WriteStation([rdir filesep 'Mod-noisy.sta.data'], s.lon, s.lat, s.eastVel, s.northVel, s.eastSig, s.northSig, s.corr, s.other1, s.tog, s.name);
      Blocks(p);
      system(sprintf('cp %s/Mod-noisy.sta.data %s/Mod-noisy%g.sta.data', rdir, rdir, i));
   end
   
end