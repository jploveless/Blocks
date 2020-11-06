function [G] = GetSarRotationPartials(Station, Block, look_vec)
% Calculate rotation partial derivatives
nStations                                   = numel(Station.lon);
nBlocks                                     = numel(Block.eulerLon);
G                                           = zeros(nStations, 3*nBlocks);
[Station.x Station.y Station.z]             = sph2cart(DegToRad(Station.lon), DegToRad(Station.lat), 6371);

for iStation = 1:nStations
   rowIdx                                   = iStation;
   colIdx                                   = (Station.blockLabel(iStation)-1)*3+1;
   R                                        = GetCrossPartials([Station.x(iStation) Station.y(iStation) Station.z(iStation)]);
   [vn_wx ve_wx vu_wx]                      = CartVecToSphVec(R(1,1), R(2,1), R(3,1), Station.lon(iStation), Station.lat(iStation));
   [vn_wy ve_wy vu_wy]                      = CartVecToSphVec(R(1,2), R(2,2), R(3,2), Station.lon(iStation), Station.lat(iStation));
   [vn_wz ve_wz vu_wz]                      = CartVecToSphVec(R(1,3), R(2,3), R(3,3), Station.lon(iStation), Station.lat(iStation));
   vlos_wx                                  = dot(look_vec(:), [ve_wx; vn_wx; vu_wx]); 
   vlos_wy                                  = dot(look_vec(:), [ve_wy; vn_wy; vu_wy]); 
   vlos_wz                                  = dot(look_vec(:), [ve_wz; vn_wz; vu_wz]); 
   R                                        = [vlos_wx vlos_wy vlos_wz];
   G(rowIdx,colIdx:colIdx+2)                = R;
end
