function [mres, chi2] = ldepstats(direc, exclud, range);
% LDEPSTATS  Calculates mean residual and chi-squared for a series of directories.
%   [MRES, CHI2] = LDEPSTATS(DIREC) calculates the mean residual MRES and chi-squared
%   value CHI2 for all results directories within DIREC.
%
%   [MRES, CHI2] = LDEPSTATS(DIREC, RANGE), given a vector whose values correspond to
%   the locking depths used in the models, will create a plot of statistics vs. locking
%   depth.
%

% Check inputs
if nargin == 2
   if ~iscell(exclud)
      range = exclud;
      clear exclud
   end
end

% Exclud blocks, if necessary
if ~exist('exclud', 'var')
   exclud = {''};
end

% Number of directories, assumed to be sequential.  Need to discard
nd = dir([direc filesep '000*']);

% Read a block file and determine included blocks
b = ReadBlock([direc filesep nd(1).name filesep 'Mod.block']);
[~, includ] = setdiff(b.name, exclud);

% Read an observation velocity file, just need one to get sigmas
obs = ReadStation([direc filesep nd(1).name filesep 'Obs.sta.data']);
in = find(ismember(obs.other1, includ));
keyboard
mres = zeros(length(nd), 1);
chi2 = mres; 

for i = 1:length(nd)
   dname = nd(i).name;
   res = ReadStation([direc filesep dname filesep 'Res.sta.data']);
   mres(i) = mean(mag([res.eastVel(in) res.northVel(in)], 2));
   chi2(i) = sum([res.eastVel(in).^2./obs.eastSig(in).^2; res.northVel(in).^2./obs.northSig(in).^2]);
end

if exist('range', 'var')
   fn = figure;
   plot(range, (chi2-min(chi2))./min(chi2)*100, 'k-');
   hold on
   plot(range, (mres-min(mres))./min(mres)*100, 'k--');
   leg = legend('\chi^2', 'Mean res. mag. (mm/yr)');
   alignleg(leg, gca, 'northeast');
   prepfigprint(fn)
   alignleg(leg, gca, 'northeast');
   xlabel('Locking depth (km)')
   ylabel('% increase')
   axis tight
   set(gca, 'ytick', 0:10:max(get(gca, 'ylim')))
end