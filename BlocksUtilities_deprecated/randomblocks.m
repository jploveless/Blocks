function randomblocks(b, S, sz, structured, outname)
% RANDOMBLOCKS tesselates an existing segment and block file
% with random polygons.
%   RANDOMBLOCKS(B, SIZE, STRUCTURED, OUTNAME) uses the block structure
%   B containing ordered coordinates (as returned from BLOCKLABEL) and 
%   generates a tesselated block and segment file within the blocks. 
%   The tesselated blocks will be of characteristic length SIZE.  If
%   STRUCTURED = -1, then the boundaries of the exterior block will be
%   used as the geometric guidelines and all other block boundaries
%   will be ignored.  If STRUCTURED = 0, all existing block boundaries
%   will remain, and all existing blocks will be tesselated into smaller
%   pieces.  If STRUCTURED is an n-by-1 array of integers in the set 
%   1:(number of blocks), then the blocks whose indices are in STRUCTURED
%   will be tesselated and all other blocks will remain as is.  The new
%   block and segment files will be written to OUTNAME.block and 
%   OUTNAME.segment, respectively.
%

% open the temporary Gmsh .geo file for writing
fid = fopen('temp.geo', 'w');
fprintf(fid, 'charl = %g;\n', sz);

% Check to see which blocks we're using
if structured == -1 % using just the exterior block
   ob = b.exteriorBlockLabel;
   fprintf(fid, 'Point(%g) = {%g, %g, 0, charl};\n', [1:numel(b.orderLon{b.exteriorBlockLabel}); b.orderLon{b.exteriorBlockLabel}'; b.orderLat{b.exteriorBlockLabel}']);
   fprintf(fid, 'CatmullRom(%g) = {%g, %g};\n', [1:numel(b.orderLon{b.exteriorBlockLabel}); 1:numel(b.orderLon{b.exteriorBlockLabel}); [2:numel(b.orderLon{b.exteriorBlockLabel}) 1]]);
   fprintf(fid, 'Line Loop(1) = {1:%g};\nPlane Surface(1) = {1};\n', numel(b.orderLon{b.exteriorBlockLabel}));
elseif sum(structured) >= 0 % using some or all blocks
   if structured == 0
      s = setdiff(1:numel(b.orderLon), b.exteriorBlockLabel);
      ob = b.exteriorBlockLabel;
   else
      s = structured;
      ob = [setdiff(1:numel(b.orderLon), s)];
   end
   pidx = 0; li = 0; % point and line indices
   for i = 1:numel(s) % for each block
      fprintf(fid, 'Point(%g) = {%g, %g, 0, charl};\n', [pidx + [1:numel(b.orderLon{s(i)})]; b.orderLon{s(i)}'; b.orderLat{s(i)}']);
      pidx = pidx + numel(b.orderLon{s(i)});
   end
   pidx = 0;
   for i = 1:numel(s)
      fprintf(fid, 'CatmullRom(%g) = {%g, %g};\n', [li + [1:numel(b.orderLon{s(i)})]; pidx + [1:numel(b.orderLon{s(i)})]; pidx + [2:numel(b.orderLon{s(i)}) 1]]);
      fprintf(fid, 'Line Loop(%g) = {%g:%g};\nPlane Surface(%g) = {%g};\n', i, li + 1, li + numel(b.orderLon{s(i)}), i, i);
      pidx = pidx + numel(b.orderLon{s(i)}); li = pidx;
   end
end
fclose(fid);

% Mesh using Gmsh
system('gmsh -2 temp.geo -o temp.msh -v 0 > junk');

% Read in the mesh file for conversion to .segment and .block files
[c, v] = msh2coords('temp.msh');

% Need to be smart about finding unique nodes, because block labeling demands it
[uc, i, j] = unique(c, 'rows');
uv = j(v);
% Also need to find unique segments
s1 = uv(:, 1:2); s2 = uv(:, 2:3); s3 = uv(:, [3 1]);
segs = [sort(s1, 2); sort(s2, 2); sort(s3, 2)];
segs = unique(segs, 'rows');

% Need to use the segment structure to find the "other" segments
if exist('s', 'var')
   os1 = ~ismember(S.westLabel, s);
   os2 = ~ismember(S.eastLabel, s);
   os = intersect(find(os1(:)), find(os2(:)));
else
   os = [];
end

% Now write the segment and block files
faultname = strvcat(strcat(repmat('seg', size(segs, 1), 1), num2str([1:size(segs, 1)]')), S.name(os, :));
lon1 = [uc(segs(:, 1), 1); S.lon1(os(:))'];
lon2 = [uc(segs(:, 2), 1); S.lon2(os(:))']; 
lat1 = [uc(segs(:, 1), 2); S.lat1(os(:))'];
lat2 = [uc(segs(:, 2), 2); S.lat2(os(:))'];
ot = ones(size(segs, 1), 1);
WriteSegment([outname '.segment'], faultname, lon1, lat1, lon2, lat2, ...
             [15*ot; S.lDep(os)], [5*ot; S.lDepSig(os)], [0*ot; S.lDepTog(os)], ...
             [90*ot; S.dip(os)], [ot; S.dipSig(os)], [0*ot; S.dipTog(os)], ...
             [0*ot; S.ssRate(os)], [ot; S.ssRateSig(os)], [0*ot; S.ssRateTog(os)], ...
             [0*ot; S.dsRate(os)], [ot; S.dsRateSig(os)], [0*ot; S.dsRateTog(os)], ...
             [0*ot; S.tsRate(os)], [ot; S.tsRateSig(os)], [0*ot; S.tsRateTog(os)], ...
             [0*ot; S.bDep(os)], [ot; S.bDepSig(os)], [0*ot; S.bDepTog(os)], ...
             [100*ot; S.res(os)], [0*ot; S.resOver(os)], [0*ot; S.resOther(os)], ...
             [0*ot; S.patchFile(os)], [0*ot; S.patchTog(os)], [0*ot; S.other3(os)], ...
             [0*ot; S.patchSlipFile(os)], [0*ot; S.patchSlipTog(os)], [0*ot; S.other6(os)], ...
             [0*ot; S.other7(os)], [0*ot; S.other8(os)], [0*ot; S.other9(os)], ...
             [0*ot; S.other10(os)], [0*ot; S.other11(os)], [0*ot; S.other12(os)]); 

% Element centroids can be block interior points
xa = reshape(c(v, 1), size(v));
ya = reshape(c(v, 2), size(v));
za = reshape(c(v, 3), size(v));
[xc, yc, zc] = centroid3(xa, ya, za);
zt = zeros(size(xc));
xc = [xc; b.interiorLon(ob)]; yc = [yc; b.interiorLat(ob)];
blockname = strvcat(strcat(repmat('block', size(xc)), num2str([1:numel(xc)]')), b.name(ob, :));
WriteBlocks([outname '.block'], blockname, xc, yc, ...
            [zt; b.eulerLon(ob)], [zt; b.eulerLonSig(ob)], ...
            [zt; b.eulerLat(ob)], [zt; b.eulerLatSig(ob)], ...
            [zt; b.rotationRate(ob)], [zt; b.rotationRateSig(ob)], ...
            [zt; b.rotationInfo(ob)], [zt; b.aprioriTog(ob)], ...
            [zt; b.other1(ob)], [zt; b.other2(ob)], ...
            [zt; b.other3(ob)], [zt; b.other4(ob)], ...
            [zt; b.other5(ob)], [zt; b.other6(ob)]);