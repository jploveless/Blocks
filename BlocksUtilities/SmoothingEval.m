function SmoothingEval(commandFile, n, varargin)
%
% SMOOTHINGEVAL generates a series of block models to evaluate
% the effects of the triangular smoothing parameter on mean
% fault slip magnitude and residuals.
%
%   SMOOTHINGEVAL(COMMAND, N) uses the command file COMMAND as a 
%   template and runs a block model for each smoothing value in 
%   the interval [0:N:1].  The results are parsed and assembled in
%   a plot showing the chi-squared value and mean slip magnitude
%   for each triangular patched region as a function of smoothing
%   parameter.
%
%   SMOOTHINGEVAL(COMMAND, BETA) allows specification of the beta 
%   values to be used by the iterations.  For example, it is 
%   adviseable to calculate beta with small intervals between 0 
%   and 0.1, while an interval of 0.05 or even 0.1 thereafter is
%   probably sufficient.
%

[pa, na, xt] = fileparts(commandFile);
Command = ReadCommand(commandFile);
p = ReadPatches(Command.patchFileNames);

if numel(n) == 1
   smooth = 0:n:1;
else
   smooth = n;
end

if nargin == 3
   outdir = varargin{:};
else
   outdir = pwd;
end

if exist(outdir) ~= 7
   mkdir(outdir);
   dirs = [];
else
   dirs = dir([outdir filesep '000*']);
end

if ~isempty(dirs) % if the output directory isn't empty, we've done the calculations and just need to extract results
   [selslips, delslips] = deal(cell(1, numel(dirs)));
   [sslips, dslips] = deal(zeros(sum(p.nEl), numel(dirs)));
   [minselslips, maxselslips, mindelslips, maxdelslips, meanselslips, meandelslips] = deal(zeros(numel(dirs), numel(p.nEl)));

   parfor (i = 1:numel(dirs))
      r = ReadStation([outdir filesep dirs(i).name filesep 'Res.sta.data']);
      velvec = [r.eastVel(:); r.northVel];
      sigvec = [r.eastSig(:); r.northSig];
      chi2(i) = sum(velvec.^2./sigvec.^2); % Calculate chi-squared
      [C, V, tSlip] = PatchData([outdir filesep dirs(i).name filesep 'Mod.patch']);
      sslips(:, i) = tSlip(:, 1);
      dslips(:, i) = tSlip(:, 2);
      selslips{i} = subset(tSlip(:, 1), p.nEl);
      delslips{i} = subset(tSlip(:, 2), p.nEl);
      minselslips(i, :) = cellfun(@min, selslips{i});
      maxselslips(i, :) = cellfun(@max, selslips{i});
      mindelslips(i, :) = cellfun(@min, delslips{i});
      maxdelslips(i, :) = cellfun(@max, delslips{i});
      meanselslips(i, :) = cellfun(@mean, selslips{i});
      meandelslips(i, :) = cellfun(@mean, delslips{i});
   end   
keyboard   
else

   chi2 = zeros(numel(smooth), 1);
   mslips = zeros(numel(smooth), numel(p.nEl));
   
   for i = 1:numel(smooth) % for each smoothing value...
      Command.triSmooth = smooth(i); % replace the command file's smoothing value
      name = [pa, filesep, na, '_smooth', num2str(smooth(i), '%.2g'), xt]; 
      WriteCommand(Command, name); % write the new command file
      Blocks(name); % run blocks
      r = ReadStation([newdir 'Res.sta.data']); % Read velocity residuals
      velvec = [r.eastVel(:); r.northVel];
      sigvec = [r.eastSig(:); r.northSig];
      chi2(i) = sum(velvec.^2./sigvec.^2); % Calculate chi-squared
      [C, V, tSlip] = PatchData([newdir 'Mod.patch']); % Read the patch data
   %   slipMags = cumsum(mag(tSlip(:, 1:2), 2), 1); % Calculate the summed velocity magnitude for each patch
      slipMags = subset(tSlip(:, 2), p.nEl);
      mslips(i, :) = cellfun(@mean, slipMags);
   end
   save([outdir filesep na '_smooth'], 'smooth', 'mslips', 'chi2');
end

% Plotting routine
figure; axis;
fs = 14;
ax1 = get(gcf, 'children');
misfit = plot(smooth, chi2, 'color', 'k', 'parent', ax1); hold on
ax2 = axes('position', get(ax1, 'position'));
triss = plot(smooth, sign(mslips).*log10(abs(mslips)), '-*', 'parent', ax2);
set(ax2, 'xaxislocation', 'bottom', 'yaxislocation', 'right', 'color', 'none');

% axis labels
y1 = ylabel('$\chi^2$', 'fontsize', fs, 'parent', ax1, 'interpreter', 'latex');
y2 = ylabel('$\log_{10} \bar{s}_T$ (mm/yr)', 'fontsize', fs, 'parent', ax2, 'interpreter', 'latex');
x2 = xlabel('$\beta$', 'fontsize', fs, 'parent', ax2, 'interpreter', 'latex');

% don't show beta = 0
set(ax1, 'xlim', [smooth(2) 1], 'fontsize', fs);
set(ax2, 'xlim', [smooth(2), 1], 'xtick', [0 1], 'fontsize', fs);

% make the legend
names = strvcat('Misfit', [repmat('fault', numel(p.nEl), 1) num2str([1:numel(p.nEl)]')]);
legend([misfit; triss], names, 'location', 'northwest'); 
