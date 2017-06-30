function [r, trig, strainm] = resid2strain(direc, exclud, int, ang)
% RESID2STRAIN  Calculates strain from block model residuals
%   RESID2STRAIN(DIREC) uses the files in the output directory DIREC to 
%   calculate strain based on a triangulation of the residual velocity 
%   field.  The entire directory is needed because the stations must
%   be assigned to a particular block.  The function is designed for the
%   overdetermined solution using Blocks_noise.m.
%

% Default is for boundary-crossing triangles to be discarded
if ~exist('int', 'var')
   int = 1;
end

% Default is for triangles with minimum angle less than 5 degrees to be discarded
if ~exist('ang', 'var')
   ang = 0;
end

% Initialize strain arrays
[i1, i2, strainm, triblock, triarea] = deal([]);
trig = zeros(0, 3);

% Read residual data
r = ReadStation([direc filesep 'Res.sta.data']);

% Read block structure
b = ReadBlock([direc filesep 'Mod.block']);

% Read segment structure
s = ReadSegmentTri([direc filesep 'Mod.segment']);
s = OrderEndpoints(s);
[s.midLon, s.midLat] = deal(0.5*(s.lon1 + s.lon2), 0.5*(s.lat1 + s.lat2));

% Run block label
[s, b, r] = BlockLabel(s, b, r);

% Loop over all blocks
[junk, up] = unique([r.lon r.lat], 'rows');
r = structsubset(r, sort(up));

% Find all non-exterior blocks
interior = setdiff(1:length(b.interiorLon), b.exteriorBlockLabel);

% Find all plateau blocks
warning off MATLAB:CELL:SETDIFF:RowsFlagIgnored % Turn off the warning in case we're using cells
[junk, plateau] = setdiff(b.name, exclud, 'rows');
warning on all

for i = plateau
   toss = [];
   % Find stations on this block
   ob = find(r.blockLabel == i);
   % Extract subsets of the station data
   tlon = r.lon(ob); tlat = r.lat(ob); te = r.eastVel(ob); tn = r.northVel(ob); se = r.eastSig(ob); sn = r.northSig(ob);
   [tx, ty] = gmtutm(tlon, tlat, getutmzone(tlon, tlat), 0);
   % Do the Delaunay triangulation of stations on this block
   tri = delaunay(tlon, tlat);
   % Discard any triangles whose sides cross block boundaries
   if int == 1
      [p1x, p3x] = meshgrid([tlon(tri(:, 1)); tlon(tri(:, 2)); tlon(tri(:, 3))], b.orderLon{i}(1:end));
      [p1y, p3y] = meshgrid([tlat(tri(:, 1)); tlat(tri(:, 2)); tlat(tri(:, 3))], b.orderLat{i}(1:end));
      [p2x, p4x] = meshgrid([tlon(tri(:, 2)); tlon(tri(:, 3)); tlon(tri(:, 1))], [b.orderLon{i}(2:end); b.orderLon{i}(1)]);
      [p2y, p4y] = meshgrid([tlat(tri(:, 2)); tlat(tri(:, 3)); tlat(tri(:, 1))], [b.orderLat{i}(2:end); b.orderLat{i}(1)]);
      [xi, yi]   = pbisect([p1x(:) p1y(:)], [p2x(:) p2y(:)], [p3x(:) p3y(:)], [p4x(:) p4y(:)]);
      [tidx, junk] = meshgrid(repmat([1:size(tri, 1)]', 3, 1), 1:size(b.orderLon{i}, 1));
      toss = unique(tidx(find(~isnan(xi))));
   end
   
   % Discard any triangles whose angles are shallower than 5 degrees
   dx = diff(tx(tri(:, [1:3, 1])), 1, 2)'; dx = dx(:);
   dy = diff(ty(tri(:, [1:3, 1])), 1, 2)'; dy = dy(:);
   aa = [dx dy];
   bb = zeros(size(aa));
   bb(1:3:end, :) = aa(2:3:end, :);
   bb(2:3:end, :) = aa(3:3:end, :);
   bb(3:3:end, :) = aa(1:3:end, :);
   dots = dot(aa, bb, 2);
   angs = acosd(dots./(mag(aa, 2).*mag(bb, 2)));
   toss = [toss; union(ceil(find(angs <= ang)/3), ceil(find(180 - angs <= ang)/3))];

   if ~isempty(toss)
      tri(toss, :) = [];
   end
   
   gtv = ob(tri);
   if size(gtv, 2) == 3
      trig = [trig; gtv];
   else
      trig = [trig; gtv'];
   end
   % Calculate the strain tensor for each trio of stations
   for j = 1:size(tri, 1)
      % Calculate tri. area
      tria = areaint(tlat(tri(j, :)), tlon(tri(j, :)), almanac('earth', 'ellipsoid', 'kilometers'));
      triarea = [triarea; tria];
      G = zeros(6); d = zeros(6, 1); W = d;
      G(:, 1:2) = repmat(eye(2), 3, 1);
      G(1:2:end, 3:4) = [tx(tri(j, :)), ty(tri(j, :))]; % Coordinates, already in m from UTM conversion
      G(2:2:end, 5:6) = [tx(tri(j, :)), ty(tri(j, :))];
      d(1:2:end) = 1e-3*te(tri(j, :)); % Velocities, converted to m
      d(2:2:end) = 1e-3*tn(tri(j, :));
      W(1:2:end) = 1e-3*1./se(tri(j, :)).^2;
      W(2:2:end) = 1e-3*1./sn(tri(j, :)).^2;
      W = diag(W);
%      mest = ((G'*W*G)\eye(6))*G'*W*d;
      mest = G\d;
      E = 0.5*(mest(3:end) + mest([3; 5; 4; 6]));
      W = 0.5*(mest(3:end) - mest([3; 5; 4; 6]));
      i1 = [i1; E(1) + E(4)];
      i2 = [i2; 0.5*(E(1)*E(2) + E(1)*E(3) + E(2)*E(3) - E(1)^2 - E(4)^2)];
      strainm = [strainm; sqrt(0.5*sum(E.^2))];
      triblock = [triblock; i];
   end
end
save([direc filesep 'Strain.delaunay'], 'i1', 'i2', 'strainm', 'triblock', 'triarea', '-mat')
%keyboard
%%meshview([r.lon, r.lat], trig, i1, fn);
%fn = figure; hold on;
%meshview([r.lon, r.lat], trig, strainm, fn);
%line([s.lon1'; s.lon2'], [s.lat1'; s.lat2'], 'color', 'r', 'linewidth', 2);
