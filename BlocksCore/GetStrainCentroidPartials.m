function [G, strainBlockIdx, cLon, cLat, toDelete]  = GetStrainCentroidPartials(Block, Station, Segment)
% Calculate strain partial derivatives
nStations                                   = numel(Station.lon);
nBlocks	                                   = numel(Block.interiorLon);
G                                           = zeros(3*nStations, 3*nBlocks);
R              				                 = 6371*1e6; % radius of Earth in mm
minSta                                      = 3; % 3 for Jack

% Convert station positions into radians and co-latitude
Station.lon                                 = deg2rad(Station.lon);
Station.lat(find(Station.lat)>=0)           = 90 - Station.lat(find(Station.lat)>=0);
Station.lat(find(Station.lat)<0)            = -90 - Station.lat(find(Station.lat)<0);
Station.lat                                 = deg2rad(Station.lat);

% Create array containing column index limits of the design matrix
firstCol                                    = 3*Station.blockLabel - 2;
lastCol                                     = 3*Station.blockLabel;

[cLon, cLat]									 	  = deal(zeros(nBlocks, 1));	

for iStation = 1:nStations
   if Block.rotationInfo(Station.blockLabel(iStation)) == 1
      % Partials with block centroid
      % The block "centroid" is only an approximation given by the mean of its coordinates
      % This should work reasonably well for the "chopped" case but is not exact or general
      idx1                                  = find(Segment.eastLabel == Station.blockLabel(iStation));
      idx2                                  = find(Segment.westLabel == Station.blockLabel(iStation));
      idx                                   = union(idx1, idx2);
      lonVec                                = [Segment.lon1(idx);Segment.lon2(idx)];
      latVec                                = [Segment.lat1(idx);Segment.lat2(idx)];
%       [lat0 lon0]                           = meanm(latVec(:), lonVec(:));
      lat0                                  = mean(latVec(:));
      lon0                                  = mean(lonVec(:));
      cLon(Station.blockLabel(iStation))	  = lon0;
      cLat(Station.blockLabel(iStation))	  = lat0;
      lon0                                  = deg2rad(lon0);
      lat0(lat0>=0)                         = 90 - lat0(lat0>=0);
      lat0(lat0<0)                          = -90 - lat0(lat0<0);      
      lat0                                  = deg2rad(lat0);
      G(3*iStation-2:3*iStation, firstCol(iStation):lastCol(iStation)) = [R*(Station.lon(iStation)-lon0).*sin(lat0) R*(Station.lat(iStation)-lat0) 0;...
                                                                          0 R*(Station.lon(iStation)-lon0).*sin(lat0) R*(Station.lat(iStation)-lat0);...
                                                                          0 0 0];
   end
end

% Get rid of blocks that don't have enough stations on them
for i = 1:size(G, 2)/3;
   j                                        = 3*i-1;
   numSta(i)                                = numel(find(G(:, j)));
end
toDelete                                    = [3*find(numSta<2*minSta)-2 3*find(numSta<2*minSta)-1 3*find(numSta<2*minSta)];
strainBlockIdx                              = setdiff(1:1:nBlocks*3, toDelete);
G(:,toDelete)                               = [];
