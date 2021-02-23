function G = GetVelRotPartials(lon, lat)

nStations                  = numel(lon);
G                          = zeros(3*nStations, 6);
for i = 1:nStations
   rowIdx                  = (i-1)*3+1;
   colIdx                  = 1;
   [x y z]                 = sph2cart(deg2rad(lon(i)), deg2rad(lat(i)), 6371e6);
   R                       = GetCrossPartials([x y z]);
   [vn_wx ve_wx vu_wx]     = CartVecToSphVec(R(1,1), R(2,1), R(3,1), lon(i), lat(i));
   [vn_wy ve_wy vu_wy]     = CartVecToSphVec(R(1,2), R(2,2), R(3,2), lon(i), lat(i));
   [vn_wz ve_wz vu_wz]     = CartVecToSphVec(R(1,3), R(2,3), R(3,3), lon(i), lat(i));
   R                       = [ve_wx ve_wy ve_wz ; vn_wx vn_wy vn_wz ; vu_wx vu_wy vu_wz];
   G(rowIdx:rowIdx+2,colIdx:colIdx+5) = [R eye(3)];
end

G(3:3:end, :)              = [];
G(:, 6)                    = [];
