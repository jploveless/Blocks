function adjustpatchpost(patch)
% ADJUSTPATCHPOST  Processes an adjusted patch file.
%   ADJUSTPATCHPOST(PATCH) uses the geometry contained in PATCH (either a .msh 
%   or .mat file) and the adjusted segment file written by ADJUSTPATCHPRE and 
%   modified using SegmentManagerGui to write a new patch file with the adjusted
%   top edge coordinates.  The file will be written to PATCH_adjustNNN.mat, where
%   NNN in an incremental number beginning with 001.
%

% Determine segment name and read in
[pa, na, ex] = fileparts(patch);
snames = dir([patch(1:end-4) '_topedge*.segment']);
for i = 1:numel(snames)
   dn(i) = snames(i).datenum;
end
[junk, md] = max(dn);
sname = [pa filesep snames(md).name];
seg = ReadSegmentTri(sname);

% Read patch file
p = ReadPatches(patch);

% Find the coordinates that line the top edge
cz = find(p.c(:, 3) == max(p.c(:, 3)));

% Find the nodes containing those coordinates
vz = ismember(p.v, cz);

% Find the elements containing 2 of those nodes
topels = find(sum(vz, 2) == 2);
vzt = vz(topels, :);
topv = vzt.*p.v(topels, :);

% Rewrite the top node coordinates
for i = 1:length(topels)
   p.c(topv(i, find(topv(i, :), 1, 'first')), 1) = seg.lon1(i);  
   p.c(topv(i, find(topv(i, :), 1, 'last')), 1) = seg.lon2(i); 
   p.c(topv(i, find(topv(i, :), 1, 'first')), 2) = seg.lat1(i); 
   p.c(topv(i, find(topv(i, :), 1, 'last')), 2) = seg.lat2(i); 
end

% Write the new patch file
pname = [patch(1:end-4) '_adjust']; % root file name for now
ap = dir([pname '*']); % find all the patch files that have been adjusted already
if ~isempty(ap)
   nap = char(ap.name);
   nap = str2num(nap(:, (end-6):(end-4)));
   new = num2str(max(nap)+1, '%03g');
else
   new = '001';
end
pname = [pname new '.mat'];
save(pname, '-struct', 'p');
