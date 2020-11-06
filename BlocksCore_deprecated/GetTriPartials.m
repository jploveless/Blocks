function [G, tz, ts, td] = GetTriPartials(Patches, Station, pr)
% Calculate elastic partial derivatives for triangular elements
if ~exist('pr', 'var')
   pr = 0.25;
end
nStations                                      = numel(Station.lon);
nPatches                                       = numel(Patches.lon1);
G                                              = zeros(3*nStations, 3*nPatches);
tz                                             = 3*ones(nPatches, 1);
tz(abs(abs(Patches.dip) - 90) > 2.5)           = 2;
ts                                             = Patches.strike;
td                                             = Patches.dip;
[v1 v2 v3]                                     = deal(cell(1, nPatches));
if nPatches > 0;
   parfor (iPatches = 1:nPatches)
      % Calculate elastic deformation for dip and strike slip components

      % Do local oblique Mercator projection
      [p, s]                                   = ProjectTriCoords([Patches.lon1(iPatches) Patches.lat1(iPatches) Patches.z1(iPatches) Patches.lon2(iPatches) Patches.lat2(iPatches) Patches.z2(iPatches) Patches.lon3(iPatches) Patches.lat3(iPatches) Patches.z3(iPatches)], [Station.lon, Station.lat]);
      projstrikes(iPatches)                    = p.Strike;
      [ux, uy, uz]                             = tri_disl([p.px1, p.px2, p.px3], [p.py1, p.py2, p.py3], abs([p.z1, p.z2, p.z3]), s.tpx, s.tpy, -1, 0, 0, 0.25);
      v1{iPatches}                             = reshape([ux uy uz]', 3*nStations, 1);
      if tz(iPatches) == 2
         [ux, uy, uz]                          = tri_disl([p.px1, p.px2, p.px3], [p.py1, p.py2, p.py3], abs([p.z1, p.z2, p.z3]), s.tpx, s.tpy, 0, -1, 0, 0.25);
         v2{iPatches}                          = reshape([ux uy uz]', 3*nStations, 1);
         v3{iPatches}                          = zeros(3*nStations, 1);
      else
         [ux, uy, uz]                          = tri_disl([p.px1, p.px2, p.px3], [p.py1, p.py2, p.py3], abs([p.z1, p.z2, p.z3]), s.tpx, s.tpy, 0, 0, -1, 0.25);
         v3{iPatches}                          = reshape([ux uy uz]', 3*nStations, 1);
         v2{iPatches}                          = zeros(3*nStations, 1);
      end   
   end
   G(:, 1:3:end) = cell2mat(v1);
   G(:, 2:3:end) = cell2mat(v2);
   G(:, 3:3:end) = cell2mat(v3);
   G = xyz2enumat(G, -projstrikes + 90);
end