function topels = adjustpatchpre(patch)
% ADJUSTPATCHPRE  Prepares a patch file for surface trace adjustment.
%   TOPELS = ADJUSTPATCHPRE(PATCH) uses the geometry contained in PATCH (either
%   a .msh or .mat file) to determine which elements line the top of the mesh.  
%   The zero-depth element edges are then written to a segment file, which can
%   be adjusted using SegmentManagerGui.  Then, the companion function 
%   ADJUSTPATCHPOST can be used to stitch the adjusted coordinates into a new
%   version of the mesh.
%

% Read patch file
p = ReadPatches(patch);

% Find the coordinates that line the top edge
cz = find(p.c(:, 3) == max(p.c(:, 3)));

% Find the nodes containing those coordinates
vz = ismember(p.v, cz);

% Find the elements containing 2 of those nodes
topels = find(sum(vz, 2) == 2);
vzt = vz(topels, :);
keyboard

% Lons. and lats. of top nodes
toplons = vzt.*reshape(p.c(p.v(topels, :), 1), length(topels), 3);
toplats = vzt.*reshape(p.c(p.v(topels, :), 2), length(topels), 3);

% Extract the lats. and lons.
for i = 1:length(topels)
   s.lon1(i) = toplons(i, find(toplons(i, :), 1, 'first')); 
   s.lon2(i) = toplons(i, find(toplons(i, :), 1, 'last')); 
   s.lat1(i) = toplats(i, find(toplats(i, :), 1, 'first')); 
   s.lat2(i) = toplats(i, find(toplats(i, :), 1, 'last'));
end
s.name = [repmat('seg', i, 1) num2str([1:i]')];

sname = [patch(1:end-4) '_topedge001.segment'];
WriteSegmentStruct(sname, s);