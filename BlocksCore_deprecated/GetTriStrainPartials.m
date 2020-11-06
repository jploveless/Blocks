function [G, tz, ts, td] = GetTriStrainPartials(Patches, Station)
% Calculate elastic strain partial derivatives for triangular elements
nStations                                      = numel(Station.lon);
nPatches                                       = numel(Patches.lon1);
G                                              = zeros(6*nStations, 3*nPatches);
tz                                             = zeros(nPatches, 1);
ts                                             = zeros(nPatches, 1);
td                                             = zeros(nPatches, 1);
[v1 v2 v3]                                     = deal(cell(1, nPatches));
if nPatches > 0;
   parfor (iPatches = 1:nPatches)
      % Calculate elastic deformation for dip and strike slip components
      [uxx, uyy, uzz,...
       uxy, uxz, uyz, baz]                     = local_tri_strain_calc(Patches.lon1(iPatches), Patches.lat1(iPatches), Patches.z1(iPatches), Patches.lon2(iPatches), Patches.lat2(iPatches), Patches.z2(iPatches), Patches.lon3(iPatches), Patches.lat3(iPatches), Patches.z3(iPatches), Station.lon, Station.lat, -Station.z, -1, 0, 0, 0.25);
      ts(iPatches)                             = baz;
      v1{iPatches}                             = reshape([uxx uyy uzz uxy uxz uyz]', 6*nStations, 1);
      [str, dip]                               = findplane([Patches.x1(iPatches) Patches.y1(iPatches) Patches.z1(iPatches)], [Patches.x2(iPatches) Patches.y2(iPatches) Patches.z2(iPatches)], [Patches.x3(iPatches) Patches.y3(iPatches) Patches.z3(iPatches)]);
      td(iPatches)                             = dip;
      if abs(abs(dip) - 90) > 1;
         [uxx, uyy, uzz,...
          uxy, uxz, uyz, baz]                  = local_tri_strain_calc(Patches.lon1(iPatches), Patches.lat1(iPatches), Patches.z1(iPatches), Patches.lon2(iPatches), Patches.lat2(iPatches), Patches.z2(iPatches), Patches.lon3(iPatches), Patches.lat3(iPatches), Patches.z3(iPatches), Station.lon, Station.lat, -Station.z, 0, -1, 0, 0.25);
         v2{iPatches}                          = reshape([uxx uyy uzz uxy uxz uyz]', 6*nStations, 1);
         v3{iPatches}                          = zeros(6*nStations, 1);
         tz(iPatches)                          = 2;
      else
         [uxx, uyy, uzz,...
          uxy, uxz, uyz, baz]                  = local_tri_strain_calc(Patches.lon1(iPatches), Patches.lat1(iPatches), Patches.z1(iPatches), Patches.lon2(iPatches), Patches.lat2(iPatches), Patches.z2(iPatches), Patches.lon3(iPatches), Patches.lat3(iPatches), Patches.z3(iPatches), Station.lon, Station.lat, -Station.z, 0, 0, -1, 0.25);
         v3{iPatches}                          = reshape([uxx uyy uzz uxy uxz uyz]', 6*nStations, 1);
         v2{iPatches}                          = zeros(6*nStations, 1);
         tz(iPatches)                          = 3;
      end   
   end
   G(:, 1:3:end) = cell2mat(v1);
   G(:, 2:3:end) = cell2mat(v2);
   G(:, 3:3:end) = cell2mat(v3);
end

%G(3:6:end, :) = -G(3:6:end, :);
G(5:6:end, :) = -G(5:6:end, :);
G(6:6:end, :) = -G(6:6:end, :);
