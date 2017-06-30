function [G, tz] = GetTriPartialsx(Patches, Station)
% Calcuye elastic partial derivatives for triangular elements
nStations                                      = numel(Station.x);
nPatches                                       = numel(Patches.x1);
G                                              = zeros(3*nStations, 3*nPatches);
tz                                             = zeros(nPatches, 1);
tz(abs(Patches.dip - 90) > 1)                  = 2;
tz(tz == 0)                                    = 3;
[v1 v2 v3]                                     = deal(cell(1, nPatches));
if nPatches > 0;
   parfor (iPatches = 1:nPatches)
      % Calculate elastic deformation for dip and strike slip components
	  [ux, uy, uz]                             = tri_dislz([Patches.x1(iPatches), Patches.x2(iPatches), Patches.x3(iPatches)], [Patches.y1(iPatches), Patches.y2(iPatches), Patches.y3(iPatches)], [Patches.z1(iPatches), Patches.z2(iPatches), Patches.z3(iPatches)], Station.x, Station.y, Station.z, -1, 0, 0, 0.25);
	  v1{iPatches}                             = reshape([ux uy uz]', 3*nStations, 1);
	  if tz(iPatches) == 2;
		 [ux, uy, uz]                          = tri_dislz([Patches.x1(iPatches), Patches.x2(iPatches), Patches.x3(iPatches)], [Patches.y1(iPatches), Patches.y2(iPatches), Patches.y3(iPatches)], [Patches.z1(iPatches), Patches.z2(iPatches), Patches.z3(iPatches)], Station.x, Station.y, Station.z, 0, -1, 0, 0.25);
		 v2{iPatches}                          = reshape([ux uy uz]', 3*nStations, 1);
		 v3{iPatches}                          = zeros(3*nStations, 1);
	  else
		 [ux, uy, uz]                          = tri_dislz([Patches.x1(iPatches), Patches.x2(iPatches), Patches.x3(iPatches)], [Patches.y1(iPatches), Patches.y2(iPatches), Patches.y3(iPatches)], [Patches.z1(iPatches), Patches.z2(iPatches), Patches.z3(iPatches)], Station.x, Station.y, Station.z, 0, 0, -1, 0.25);
		 v3{iPatches}                          = reshape([ux uy uz]', 3*nStations, 1);
		 v2{iPatches}                          = zeros(3*nStations, 1);
	  end   
   end
   G(:, 1:3:end) = cell2mat(v1);
   G(:, 2:3:end) = cell2mat(v2);
   G(:, 3:3:end) = cell2mat(v3);
end