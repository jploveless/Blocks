function plotselfstress(seg, idx, S, SS, comp)
% COMP should be a string giving the field of S and SS to be plotted.

x = [seg.lon1(idx(:))'; seg.lon2(idx(:))'; seg.lon2(idx(:))'; seg.lon1(idx(:))'];
y = [seg.lat1(idx(:))'; seg.lat2(idx(:))'; seg.lat2(idx(:))'; seg.lat1(idx(:))'];
z = -[0*seg.lon1(idx(:))'; 0*seg.lon2(idx(:))'; seg.lDep(idx(:))'; seg.lDep(idx(:))'];

figure
patch(x, y, z, getfield(S, comp)')
figure
patch(x, y, z, getfield(SS, comp)')