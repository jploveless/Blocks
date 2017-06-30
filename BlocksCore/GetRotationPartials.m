function [G] = GetRotationPartials(Segment, Station, Command, Block)
% Calculate rotation partial derivatives
nStations                                   = numel(Station.lon);
nBlocks                                     = numel(Block.eulerLon);
G                                           = zeros(3*nStations, 3*nBlocks);
for iStation = 1:nStations
   rowIdx                                   = (iStation-1)*3+1;
   colIdx                                   = (Station.blockLabel(iStation)-1)*3+1;
   R                                        = GetCrossPartials([Station.x(iStation) Station.y(iStation) Station.z(iStation)]);
   [vn_wx ve_wx vu_wx]                      = CartVecToSphVec(R(1,1), R(2,1), R(3,1), Station.lon(iStation), Station.lat(iStation));
   [vn_wy ve_wy vu_wy]                      = CartVecToSphVec(R(1,2), R(2,2), R(3,2), Station.lon(iStation), Station.lat(iStation));
   [vn_wz ve_wz vu_wz]                      = CartVecToSphVec(R(1,3), R(2,3), R(3,3), Station.lon(iStation), Station.lat(iStation));
   R                                        = [ve_wx ve_wy ve_wz ; vn_wx vn_wy vn_wz ; vu_wx vu_wy vu_wz];
   G(rowIdx:rowIdx+2,colIdx:colIdx+2)       = R;
end
