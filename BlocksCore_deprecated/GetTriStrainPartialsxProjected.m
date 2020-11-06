function [G, tz, ts, str, dip] = GetTriStrainPartialsxProjected(Patches, Station)
% Calculate elastic strain partial derivatives for triangular elements
nStations                                      = numel(Station.lon);
nPatches                                       = numel(Patches.lon1);
G                                              = zeros(6*nStations, 3*nPatches);
tz                                             = zeros(nPatches, 1);
ts                                             = zeros(nPatches, 1);
[v1 v2 v3]                                     = deal(cell(1, nPatches));
if nPatches > 0;
   parfor (iPatches = 1:nPatches)
      % Calculate elastic deformation for dip and strike slip components
      [uxx, uyy, uzz,...
       uxy, uxz, uyz]                          = tri_strain([Patches.lon1(iPatches) Patches.lon2(iPatches) Patches.lon3(iPatches)], [Patches.lat1(iPatches) Patches.lat2(iPatches) Patches.lat3(iPatches)], -[Patches.z1(iPatches) Patches.z2(iPatches) Patches.z3(iPatches)], Station.lon, Station.lat, -Station.z, -1, 0, 0, 0.25);
      [str, dip]                               = findplane([Patches.lon1(iPatches) Patches.lat1(iPatches) Patches.z1(iPatches)], [Patches.lon2(iPatches) Patches.lat2(iPatches) Patches.z2(iPatches)], [Patches.lon3(iPatches) Patches.lon3(iPatches) Patches.z3(iPatches)]);
      [n, s, d]                                = rotplane(str, dip, 0, [uxx uyy uzz uxy uyz uxz]);
      v1{iPatches}                             = reshape([uxx uyy uzz uxy uxz uyz]', 6*nStations, 1);
      if abs(abs(dip) - 90) > 1;
         [uxx, uyy, uzz,...
         uxy, uxz, uyz]                        = tri_strain([Patches.lon1(iPatches) Patches.lon2(iPatches) Patches.lon3(iPatches)], [Patches.lat1(iPatches) Patches.lat2(iPatches) Patches.lat3(iPatches)], -[Patches.z1(iPatches) Patches.z2(iPatches) Patches.z3(iPatches)], Station.lon, Station.lat, -Station.z, 0, -1, 0, 0.25);
         [n, s, d]                             = rotplane(str, dip, 0, [uxx uyy uzz uxy uyz uxz]);
         v2{iPatches}                          = reshape([s, d, n]', 3*nStations, 1);
         v3{iPatches}                          = zeros(6*nStations, 1);
         tz(iPatches)                          = 2;
      else
        [uxx, uyy, uzz,...
         uxy, uxz, uyz]                        = tri_strain([Patches.lon1(iPatches) Patches.lon2(iPatches) Patches.lon3(iPatches)], [Patches.lat1(iPatches) Patches.lat2(iPatches) Patches.lat3(iPatches)], -[Patches.z1(iPatches) Patches.z2(iPatches) Patches.z3(iPatches)], Station.lon, Station.lat, -Station.z, 0, 0, -1, 0.25);
         [n, s, d]                             = rotplane(str, dip, 0, [uxx uyy uzz uxy uyz uxz]);
         v3{iPatches}                          = reshape([s, d, n]', 3*nStations, 1);
         v2{iPatches}                          = zeros(6*nStations, 1);
         tz(iPatches)                          = 3;
      end   
   end
   G(:, 1:3:end) = cell2mat(v1);
   G(:, 2:3:end) = cell2mat(v2);
   G(:, 3:3:end) = cell2mat(v3);
end