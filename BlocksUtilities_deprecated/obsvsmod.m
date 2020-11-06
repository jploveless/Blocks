function [s, g] = obsvsmod(direc, exclud)
% OBSVSMOD  Plots geodetic and geologic observations vs. model estimates.
%   OBSVSMOD(DIREC) plots geologic slip rate constraints vs. slip rate estimates
%   and GPS velocity components vs. their estimates in a 2-panel figure.

% Read command file
cf = dir([direc filesep '*.command']);
cf = ReadCommand([direc filesep cf(1).name]);

% Read observation files
sego = ReadSegmentTri(cf.segFileName);
stao = ReadStation([direc filesep 'Obs.sta.data']);

% Read estimation files
segm = ReadSegmentTri([direc filesep 'Mod.segment']);
stam = ReadStation([direc filesep 'Mod.sta.data']);

% Read deformation velocities
stad = ReadStation([direc filesep 'Def.sta.data']);

% Read block information for optional station exclusion
if exist('exclud', 'var')
   warning off MATLAB:CELL:SETDIFF:RowsFlagIgnored % Turn off the warning in case we're using cells
   b = ReadBlock([direc filesep 'Mod.block']);
   [~, includ] = setdiff(b.name, exclud, 'rows');
   in = find(ismember(stam.other1, includ));
   stam = structsubset(stam, in);
   stao = structsubset(stao, in);
   stad = structsubset(stad, in);
end

% Find segment indices with constraints; ignore tensiles
cidx = find(sego.ssRateTog == 1);
ssc = length(cidx);
cidx = [cidx; find(sego.dsRateTog)];
cnam = sego.name(cidx, :);
[~, cidxm] = ismember(cnam, segm.name, 'rows');

ff = figure;
set(ff, 'position', [1000 1000 1120 420]);
a1 = subplot(1, 2, 1);
segh = ploterr([-sego.ssRate(cidx(1:end-1)); sego.dsRate(cidx(end))], [-segm.ssRate(cidxm(1:end-1)); segm.dsRate(cidxm(end))], [sego.ssRateSig(cidxm(1:end-1)); sego.dsRateSig(cidxm(end))], [], 'ok');
set(segh(1), 'markersize', 20, 'markeredgecolor', [0 1 0], 'linewidth', 0.5)
set(segh(2), 'linewidth', 1)
hold on
axis([-15 25 -15 25])
aa = axis
ad = [aa(2) - aa(1); aa(4) - aa(3)];
[~, mad] = min(ad);
plot(aa(2*mad-1:2*mad), aa(2*mad-1:2*mad), 'k', 'linewidth', 1)
xlabel('Slip rate, constrained (mm/yr)', 'fontsize', 12); ylabel('Slip rate, estimated (mm/yr)', 'fontsize', 12);
axis equal; axis([aa(2*mad-1), aa(2*mad), aa(2*mad-1), aa(2*mad)])
text(aa(2*mad-1) + 0.05*min(ad), aa(2*mad) - 0.08*min(ad), 'a.', 'fontsize', 14, 'verticalalignment', 'bottom')

line([aa(2*mad-1) 0; aa(2*mad) 0], [0 aa(2*mad-1); 0 aa(2*mad)], 'color', 0.5*[1 1 1], 'linewidth', 1)
line([1 aa(2*mad)-1], [17.5 17.5], 'linewidth', 1, 'color', 'k');
line([-1 aa(2*mad-1)+1], [17.5 17.5], 'linewidth', 1, 'color', 'k');
text(1, 19.25, 'Right-lateral/reverse', 'horizontalalignment', 'left', 'fontsize', 12);
text(-1, 19.25, 'Left-lateral', 'horizontalalignment', 'right', 'fontsize', 12);

a2 = subplot(1, 2, 2);
%hhh = ploterr([stao.eastVel; stao.northVel], [stam.eastVel; stam.northVel], [], [], '.k');
hhh = scatter([stao.eastVel; stao.northVel], [stam.eastVel; stam.northVel], 20, [abs(stad.eastVel); abs(stad.northVel)], 'filled');
%set(hhh(1), 'markersize', 10)
hold on
aa = axis;
ad = [aa(2) - aa(1); aa(4) - aa(3)];
[~, mad] = min(ad);
plot(aa(2*mad-1:2*mad), aa(2*mad-1:2*mad), 'k', 'linewidth', 1)
xlabel('Component velocity, observed (mm/yr)', 'fontsize', 12); ylabel('Component velocity, estimated (mm/yr)', 'fontsize', 12); set(gca, 'yaxislocation', 'right', 'position', get(gca, 'position') + [-.08 0 0 0]);
axis equal; axis([aa(2*mad-1), aa(2*mad), aa(2*mad-1), aa(2*mad)])
text(aa(2*mad-1) + 0.05*min(ad), aa(2*mad) - 0.08*min(ad), 'b.', 'fontsize', 14, 'verticalalignment', 'bottom')

prepfigprint(ff)
cb = colorbar('location', 'south');
set(cb, 'position', get(cb, 'position').*[1.2 1 0.5 0.5], 'linewidth', 1, 'fontsize', 12, 'xtick', [0:5:15])
set(get(cb, 'xlabel'), 'string', 'Elastic velocity (mm/yr)', 'fontsize', 12);

%keyboard
set(segh(1), 'markersize', 5, 'markeredgecolor', [0 0 0], 'markerfacecolor', [1 1 1], 'linewidth', 1)

% Set ticks
xt = get(a1, 'xtick');
yt = get(a2, 'ytick');
if length(xt) > length(yt)
   set(a1, 'xtick', yt);
else
   set(a1, 'ytick', xt);
end

xt = get(a2, 'xtick'); yt = get(a2, 'ytick');
if length(xt) > length(yt)
   set(a2, 'xtick', yt);
else
   set(a2, 'ytick', xt);
end
set(a2, 'position', get(a2, 'position') + [-.03 0 0 0])

f = ['a'; 'b'; 'c'; 'd'; 'e'; 'f'; 'g'; 'h'; 'i'];
slipso = [-4; 11.7; 10; 10.9; 5; 2; 4.5; 12; -21];
% Check ordering of segments for labeling
[~, obso] = ismember(-slipso, [-sego.ssRate(cidx(1:end-1)); sego.dsRate(cidx(end))]);
slipsm = [-sego.ssRate(cidxm(1:end-1)); sego.dsRate(cidxm(end))];
slipsm = slipsm(obso);

text(-slipso, slipsm+1, f, 'parent', a1);
f = strvcat('^a Karakorum', '^b Altyn Tagh', '^c C. Kunlun', '^d C.-E. Kunlun', '^{e, f} E. Kunlun', '^g Haiyuan', '^h Ganzi', '^i HRF');
text(12*ones(size(f, 1), 1), linspace(4, -13, size(f, 1))', f, 'parent', a1, 'fontsize', 12)

print(ff, '-depsc', [direc filesep 'obsvsmod'], '-painters')