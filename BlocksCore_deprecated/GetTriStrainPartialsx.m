function [G, tz, ts, str, dip] = GetTriStrainPartialsx(Patches, Station)
% Calcuye elastic strain partial derivatives for triangular elements
nStations                                      = numel(Station.x);
nPatches                                       = numel(Patches.x1);
G                                              = zeros(6*nStations, 3*nPatches);
tz                                             = zeros(nPatches, 1);
ts                                             = zeros(nPatches, 1);
str                                            = zeros(nPatches, 1);
dip                                            = zeros(nPatches, 1);
[v1 v2 v3]                                     = deal(cell(1, nPatches));
if nPatches > 0;
   parfor (iPatches = 1:nPatches)
      % Calculate elastic deformation for dip and strike slip components
      [uxx, uyy, uzz,...
       uxy, uxz, uyz, nv]                      = tri_strain_fast([Patches.x1(iPatches) Patches.x2(iPatches) Patches.x3(iPatches)], [Patches.y1(iPatches) Patches.y2(iPatches) Patches.y3(iPatches)], abs([Patches.z1(iPatches) Patches.z2(iPatches) Patches.z3(iPatches)]), Station.x, Station.y, abs(Station.z), -1, 0, 0, 0.25);
      v1{iPatches}                             = reshape([uxx uyy uzz uxy uxz uyz]', 6*nStations, 1);
      [ss, dd]                                 = cart2sph(nv(1), nv(2), nv(3));
      ss                                       = 180 - rad2deg(ss);
      dd                                       = 90 - rad2deg(dd);
      str(iPatches)                            = ss;
      dip(iPatches)                            = dd;
      if abs(abs(dd) - 90) > 1;
         [uxx, uyy, uzz,...
         uxy, uxz, uyz]                        = tri_strain_fast([Patches.x1(iPatches) Patches.x2(iPatches) Patches.x3(iPatches)], [Patches.y1(iPatches) Patches.y2(iPatches) Patches.y3(iPatches)], abs([Patches.z1(iPatches) Patches.z2(iPatches) Patches.z3(iPatches)]), Station.x, Station.y, abs(Station.z), 0, -1, 0, 0.25);
         v2{iPatches}                          = reshape([uxx uyy uzz uxy uxz uyz]', 6*nStations, 1);
         v3{iPatches}                          = zeros(6*nStations, 1);
         tz(iPatches)                          = 2;
      else
        [uxx, uyy, uzz,...
         uxy, uxz, uyz]                        = tri_strain_fast([Patches.x1(iPatches) Patches.x2(iPatches) Patches.x3(iPatches)], [Patches.y1(iPatches) Patches.y2(iPatches) Patches.y3(iPatches)], abs([Patches.z1(iPatches) Patches.z2(iPatches) Patches.z3(iPatches)]), Station.x, Station.y, abs(Station.z), 0, 0, -1, 0.25);
         v3{iPatches}                          = reshape([uxx uyy uzz uxy uxz uyz]', 6*nStations, 1);
         v2{iPatches}                          = zeros(6*nStations, 1);
         tz(iPatches)                          = 3;
      end   
   end
   G(:, 1:3:end) = cell2mat(v1);
   G(:, 2:3:end) = cell2mat(v2);
   G(:, 3:3:end) = cell2mat(v3);
end