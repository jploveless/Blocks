function [G] = GetSlipPartials(Segment, Block)
% Calculate slip partial derivatives
nSegments                                   = numel(Segment.lon1);
nBlocks                                     = numel(Block.eulerLon);
G                                           = zeros(3*nSegments, 3*nBlocks);
for iSegment = 1:nSegments
   % Projection from Cartesian to spherical coordinates at segment mid-points
   rowIdx                                   = (iSegment-1)*3+1;
   colIdxE                                  = (Segment.eastLabel(iSegment)-1)*3+1;
   colIdxW                                  = (Segment.westLabel(iSegment)-1)*3+1;
   R                                        = GetCrossPartials([Segment.midX(iSegment) Segment.midY(iSegment) Segment.midZ(iSegment)]);
   [vn_wx ve_wx vu_wx]                      = CartVecToSphVec(R(1,1), R(2,1), R(3,1), Segment.midLon(iSegment), Segment.midLat(iSegment));
   [vn_wy ve_wy vu_wy]                      = CartVecToSphVec(R(1,2), R(2,2), R(3,2), Segment.midLon(iSegment), Segment.midLat(iSegment));
   [vn_wz ve_wz vu_wz]                      = CartVecToSphVec(R(1,3), R(2,3), R(3,3), Segment.midLon(iSegment), Segment.midLat(iSegment));
%    R                                        = [ve_wx ve_wy ve_wz ; vn_wx vn_wy vn_wz ; vu_wx vu_wy vu_wz];
   
   % Build unit vector for the fault
   % Projection on to fault strike
   faz                                      = azimuth(Segment.lat1(iSegment), Segment.lon1(iSegment), Segment.lat2(iSegment), Segment.lon2(iSegment));
   uxpar                                    = cos(deg_to_rad(90 - faz));
   uypar                                    = sin(deg_to_rad(90 - faz));
   uxper                                    = sin(deg_to_rad(faz - 90));
   uyper                                    = cos(deg_to_rad(faz - 90));
   % Projection onto fault dip
   if (Segment.lat2(iSegment) < Segment.lat1(iSegment))
      uxpar                                 = -uxpar;
      uypar                                 = -uypar;
      uxper                                 = -uxper;
      uyper                                 = -uyper;
   end

   if (Segment.dip(iSegment) ~= 90)
      sf                                    = 1/abs(cos(DegToRad(Segment.dip(iSegment))));
      R                                     = [uxpar*ve_wx+uypar*vn_wx uxpar*ve_wy+uypar*vn_wy uxpar*ve_wz+uypar*vn_wz;...
                                               sf*(uxper*ve_wx+uyper*vn_wx) sf*(uxper*ve_wy+uyper*vn_wy) sf*(uxper*ve_wz+uyper*vn_wz);...
                                               0 0 0];
   else
      sf                                    = -1;
      R                                     = [uxpar*ve_wx+uypar*vn_wx uxpar*ve_wy+uypar*vn_wy uxpar*ve_wz+uypar*vn_wz;...
                                               0 0 0;...
                                               sf*(uxper*ve_wx+uyper*vn_wx) sf*(uxper*ve_wy+uyper*vn_wy) sf*(uxper*ve_wz+uyper*vn_wz)];
   end
   G(rowIdx:rowIdx+2,colIdxE:colIdxE+2)     = R;
   G(rowIdx:rowIdx+2,colIdxW:colIdxW+2)     = -R;
%    G(rowIdx:rowIdx+2,colIdxE:colIdxE+2)     = -R;
%    G(rowIdx:rowIdx+2,colIdxW:colIdxW+2)     = R;
end
