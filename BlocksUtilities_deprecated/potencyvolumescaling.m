function potencyvolumescaling(direc, shape)
% POTENCYVOLUMESCALING  Makes a 2-panel plot showing potency-volume scaling.
%   POTENCYVOLUMESCALING(DIREC) makes a 2-panel plot showing theoretical scaling
%   of potency rate magnitude and partitioning value, assuming a set of intrablock
%   strain rates.  The block is extruded a depth equal to the median fault locking
%   depth in DIREC/Mod.segment.  The actual potency rate magnitudes and partitioning
%   values from DIREC/PotencyValues.mat are plotted as well.
%

% Load necessary information
seg = ReadSegmentTri([direc filesep 'Mod.segment']);
z = median(seg.lDep);
dd = load([direc filesep 'PotencyValues.mat']);
load exclud
[~, includ] = setdiff(dd.Block.name, exclud);

% Calculate block volume
if ~exist('shape', 'var')
   shape = 'circle';
end

% Radius, or half block width
rad = 10.^[6.15:0.01:7.9];

% Area and circumference calculation
if strmatch(shape, 'circle')
   a = pi*rad.^2;
   c = 2*pi*rad;
elseif strmatch(shape, 'square')
   a = (2*rad).^2;
   c = 8*rad;
end
% Block volume
v = a*z;
% Fault area
f = c*z;

% Intrablock potency rate for different strain rates
e = 10.^[-9:-5];
[v, e] = meshgrid(v, e);
pb = 2*e.*v;

% Potency rate partitioning, assuming unit fault slip rate
phi = pb./(pb + repmat(f, size(e, 1), 1));

% Make plot
ff = figure;
set(ff, 'position', [1000 1000 560 800])
a1 = subplot(2, 1, 1);
potp = plot(log10(v'), log10(pb'), 'color', 0.75*[1 1 1]);
hold on
plot(log10(dd.blockVolume(includ)), log10(dd.potencyBlock(includ)/3e10), 'k.', 'markersize', 20);
[r, p, lo, hi] = corrcoef(log10(dd.blockVolume(includ)), log10(dd.potencyBlock(includ)/3e10));
text(16.2, 6.5, sprintf('R^2 = %.2g^{+%.2g}_{-%.2g}\np = %.2g', r(2), hi(2)-r(2), r(2)-lo(2), p(2)), 'fontsize', 12)
set(a1, 'xlim', [14 17], 'xticklabel', [], 'ylim', [6 10.2], 'xtick', [14:17], 'ytick', [6:10]);
ylabel('log_{10} P_b (m^3/yr)', 'fontsize', 12);
text(14.1, 9.8, 'a.', 'backgroundcolor', [1 1 1], 'linewidth', 1, 'edgecolor', 'k', 'fontsize', 12)

text('interpreter', 'latex', 'string', '$$\left|{{{\epsilon}}}\right|={10^{-9}}$$', 'position', [14.25, 6.15], 'fontsize', 12)
text('interpreter', 'latex', 'string', '$$\left|{{{\epsilon}}}\right|={10^{-8}}$$', 'position', [14.25, 7.05], 'fontsize', 12)
text('interpreter', 'latex', 'string', '$$\left|{{{\epsilon}}}\right|={10^{-7}}$$', 'position', [14.25, 8.05], 'fontsize', 12)
text('interpreter', 'latex', 'string', '$$\left|{{{\epsilon}}}\right|={10^{-6}}$$', 'position', [14.25, 9.05], 'fontsize', 12)
text('interpreter', 'latex', 'string', '$$\left|{{{\epsilon}}}\right|={10^{-5}}$$', 'position', [14.25, 10.05], 'fontsize', 12)


a2 = subplot(2, 1, 2);
phip = plot(log10(v'), phi', 'color', 0.75*[1 1 1]);
hold on
plot(log10(dd.blockVolume(includ)), dd.potencyRatio(includ)./100, 'k.', 'markersize', 20);
[r, p, lo, hi] = corrcoef(log10(dd.blockVolume(includ)), log10(dd.potencyRatio(includ)));
text(16.2, .85, sprintf('R^2 = %.2g^{+%.2g}_{-%.2g}\np = %.2g', r(2), hi(2)-r(2), r(2)-lo(2), p(2)), 'fontsize', 12)


set(a2, 'xlim', [14 17], 'position', get(a2, 'position')+[0 0.1 0 0], 'xtick', [14:17], 'ytick', [0:.25:1]);
xlabel('log_{10} V_b (m^3)', 'fontsize', 12); ylabel('\phi', 'fontsize', 12);
text(14.1, .9048, 'b.', 'backgroundcolor', [1 1 1], 'linewidth', 1, 'edgecolor', 'k', 'fontsize', 12)

text('interpreter', 'latex', 'string', '$$\left|{{{\epsilon}}}\right|={10^{-9}}$$', 'position', [16.5, .07], 'fontsize', 12)
text('interpreter', 'latex', 'string', '$$\left|{{{\epsilon}}}\right|={10^{-8}}$$', 'position', [15.5, .15], 'fontsize', 12)
text('interpreter', 'latex', 'string', '$$\left|{{{\epsilon}}}\right|={10^{-7}}$$', 'position', [14.7, .36], 'fontsize', 12)
text('interpreter', 'latex', 'string', '$$\left|{{{\epsilon}}}\right|={10^{-6}}$$', 'position', [14.5, .70], 'fontsize', 12)
text('interpreter', 'latex', 'string', '$$\left|{{{\epsilon}}}\right|={10^{-5}}$$', 'position', [14.4, .92], 'fontsize', 12)

prepfigprint(ff)
set([potp phip], 'linewidth', 2)
