function S = snapsegments(s, p, sel, dtol, strthresh)
% snapsegments  Snaps segments to trace the updip edge of patches.
%   snapsegments(S, P, SEL, DTOL) moves segments in structure S so that
%   they coincide with the updip edge of a patch described in structure P.
%   Only the selected segments with indices SEL will be altered. Those 
%   segments are removed from the structure and replaced with the actual 
%   triangle edge coordinates from P. DTOL is an optional depth tolerance
%   variable and is used to allow some variation in choosing the updip edge
%   of the meshes. DTOL is a constant specifying the depth tolerance in km. 
%
%   The function operates by finding the patch whose centroid is closest to 
%   the mean of the selected segment coordinates. Then, the selected segments
%   are split or removed and replaced with new segments that overlap with the
%   updip trace of the patch. These segments have "blank" properties, i.e., 
%   the names, locking depths, dips, etc. are those of default segments, which
%   should not matter in a Blocks run since these segments will not contribute
%   to the elastic deformation field.
%
%   When selecting the segments that will be replaced by the patches, it is best
%   to select those that fully encompass the updip extent of the mesh. That is,
%   make sure that the selected segments' endpoints lie beyond (even slightly) the
%   extent of the mesh.
%

% Find center of selected segments
sc                             = [mean([s.lon1(sel); s.lon2(sel)]), mean([s.lat1(sel); s.lat2(sel)])];

% Find centroids of meshes
mn                             = length(p.nEl);
% Start and end indices
vends                          = cumsum(p.nEl(:));
vbegs                          = [1; vends(1:end-1)+1];
mc                             = zeros(mn, 2);
for i = 1:mn
   mc(i, :)                    = mean(p.c(p.v(vbegs(i):vends(i), :), 1:2), 1);
end

% Find the mesh closest to the segments
dist                           = gcdist(sc(2), sc(1), mc(:, 2), mc(:, 1));
[~, midx]                      = min(dist);

% Check for corner strike threshold specification
if ~exist('strthresh', 'var')
   strthresh = 55; % Default for edgeeelements.m
end

% Find the segments that are at the ends of the selection. These will be split, with the new endpoint
% coincident with the corner of the mesh.

% All coordinates
lons                           = [s.lon1(sel(:)); s.lon2(sel(:))];
lats                           = [s.lat1(sel(:)); s.lat2(sel(:))];
coords                         = [lons(:) lats(:)];
% Unique coordinates
[~, ucInd1]                    = unique(coords, 'rows', 'first');
[uc, ucInd2]                   = unique(coords, 'rows', 'last');
% Dangling segments are those where the unique occurrence is in the same place
endsegs                        = ismember(coords, uc(ucInd1 == ucInd2, :), 'rows');
endcol                         = endsegs;
endsegs                        = find(endsegs);
endsegs(endsegs > length(sel)) = endsegs(endsegs > length(sel)) - length(sel);
endcol                         = find(endcol);
endcol(endcol <= length(sel))  = 1;
endcol(endcol > length(sel))   = 2;
lons                           = reshape(lons, length(sel), 2);
lats                           = reshape(lats, length(sel), 2);

% Find corner coordinates of mesh. 
% - Find ordered edges
% - Find those along updip edge
% - Use distance to associate the first and last with the dangling segments
elo                            = OrderedEdges(p.c, p.v(vbegs(midx):vends(midx), :));
elo                            = elo(1, [2:end, 1]); % Ordered edge nodes
% Check for a depth tolerance
if ~exist('dtol', 'var')
  dtol                         = 0;
end
updip1                         = elo(find(abs(p.c(elo, 3)) <= dtol)); % Updip nodes
[~, nodes]                     = edgeelements(p.c, p.v(vbegs(midx):vends(midx), :), strthresh); % Updip nodes
updip                          = nodes.top;

% Find the corners
d1                             = gcdist(lats(endsegs(1), endcol(1)), lons(endsegs(1), endcol(1)), p.c(updip, 2), p.c(updip, 1));
[~, c1]                        = min(d1);
d2                             = gcdist(lats(endsegs(2), endcol(2)), lons(endsegs(2), endcol(2)), p.c(updip, 2), p.c(updip, 1));
[~, c2]                        = min(d2);

% Split the hanging segments
% New endpoints are mesh corners
nns                            = length(updip)+1; % number of new segments
newseg.lon1                    = zeros(nns, 1);
newseg.lon2                    = zeros(nns, 1);
newseg.lat1                    = zeros(nns, 1);
newseg.lat2                    = zeros(nns, 1);

newseg.lat2(1)                 = p.c(updip(c1), 2);
newseg.lon2(1)                 = p.c(updip(c1), 1);
% Other endpoint is the hanging endpoint
newseg.lat1(1)                 = lats(endsegs(1), endcol(1));
newseg.lon1(1)                 = lons(endsegs(1), endcol(1));
newseg.lat2(2)                 = p.c(updip(c2), 2);
newseg.lon2(2)                 = p.c(updip(c2), 1);
newseg.lat1(2)                 = lats(endsegs(2), endcol(2));
newseg.lon1(2)                 = lons(endsegs(2), endcol(2));

% Remaining new segments are the mesh edges
% Need to check the ordering of nodes
if abs(c2 - c1) == 1 % If opposite ends of mesh are actually ordered adjacent
   updip = updip([end, 1:end-1]);
end
newseg.lon1(3:end)             = p.c(updip(1:end-1), 1);
newseg.lat1(3:end)             = p.c(updip(1:end-1), 2);
newseg.lon2(3:end)             = p.c(updip(2:end), 1);
newseg.lat2(3:end)             = p.c(updip(2:end), 2);
newseg.name                    = [repmat('Patch', nns, 1), num2str(midx*ones(nns, 1)), repmat('_', nns, 1), num2str((1:nns)')];

% Stitch new and old segments together
% Isolate old segments
old                            = structsubset(s, setdiff(1:length(s.lon1), sel)); so = length(old.lon1);
nos                            = length(old.lon1); % number of old segments
% Check to see if any of the modified segments were triple junctions; those points need adjusting, too
ocoords                        = [old.lon1, old.lat1; old.lon2, old.lat2]; % Full array of old coordinates
tj                             = find(ismember(ocoords, coords, 'rows')); % Check to see which share a node with selected (replaced) segments
ncoords                        = [newseg.lon1, newseg.lat1; newseg.lon2, newseg.lat2]; % New coordinates
tjidx                          = dsearchn(ncoords, ocoords(tj, :)); % Find closest new node
p1idx                          = tj <= nos;
p2idx                          = tj > nos; tj(p2idx) = tj(p2idx) - nos;
old.lon1(tj(p1idx))            = ncoords(tjidx(p1idx), 1);
old.lat1(tj(p1idx))            = ncoords(tjidx(p1idx), 2);
old.lon2(tj(p2idx))            = ncoords(tjidx(p2idx), 1);
old.lat2(tj(p2idx))            = ncoords(tjidx(p2idx), 2);

% Add new endpoints and default segment properties
S                              = AddGenericSegment(old, newseg.name, newseg.lon1, newseg.lat1, newseg.lon2, newseg.lat2);
% Set patch toggles for the new segments
S.patchFile(so+1:end)          = midx;
S.patchTog(so+1:end)           = 1;








   