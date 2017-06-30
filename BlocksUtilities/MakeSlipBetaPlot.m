function [smooth, smax, smin, smean, mu, prlmu, meanRes, ax] = MakeSlipBetaPlot(direc, sel);
% DIREC is the directory where all result files are stored, SEL is a cell containing
% the selected elements.

dirs = dir([direc filesep '000*']);

smooth = dir([direc filesep '*smooth.mat']);
load(smooth.name);

smax = zeros(size(smooth, 1), numel(sel));
smin = smax;
smean = smax;
meanRes = zeros(numel(dirs), 1);
prlmu = meanRes;
ax = zeros(numel(sel) + 1, 1);

for i = 1:length(dirs)
   [c, v, slip] = PatchData([direc filesep dirs(i).name filesep 'Mod.patch']);
   s = opentxt([direc filesep dirs(i).name filesep 'Stats.txt']);
   meanRes(i) = str2num(s(end-30, 47:58));
   prlmu(i) = str2num(s(end, 45:end));
   mu = str2num(s(end-29, 47:58));
   [max, min, mean] = SelElStats(slip, sel);
   smax(i, :) = max(:, 3)';
   smin(i, :) = min(:, 3)';
   smean(i, :) = mean(:, 3)';
end
figure
for j = 1:numel(sel)
   ax(j) = subplot(numel(sel)+1, 1, j);
   plot(log10(smooth), smin(:, j), 'color', 0.5*[1 1 1]); hold on;
   plot(log10(smooth), smax(:, j), 'color', 0.5*[1 1 1]);
   plot(log10(smooth), smean(:, j), 'k');
end

subplot(numel(sel)+1, 1, numel(sel)+1);
[axs, muh, prh] = plotyy(log10(smooth), mu*ones(size(smooth)), log10(smooth), prlmu); hold on;
set(muh, 'linestyle', '--', 'color', 'k')
set(prh, 'color', 0.5*[1 1 1]);
plot(log10(smooth), meanRes, 'k', 'parent', axs(1));
keyboard
ax = [ax; axs'];