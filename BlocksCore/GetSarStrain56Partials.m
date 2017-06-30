function [G, strainBlockIdx] = GetStrain56Partials(Block, Station, Segment)
% Calculate strain partial derivatives
nStations                                   = numel(Station.lon);
nBlocks	                                   = numel(Block.interiorLon);
G                                           = zeros(2*nStations, 6*nBlocks);
R              				                 = 6371*1e6; % radius of Earth in mm
minSta                                      = 3; % 3 for Jack

% Convert station positions into radians and co-latitude
Station.lon                                 = deg2rad(Station.lon);
Station.lat(find(Station.lat)>=0)           = 90 - Station.lat(find(Station.lat)>=0);
Station.lat(find(Station.lat)<0)            = -90 - Station.lat(find(Station.lat)<0);
Station.lat                                 = deg2rad(Station.lat);

% Create array containing column index limits of the design matrix
firstCol                                    = 6*Station.blockLabel - 5;
lastCol                                     = 6*Station.blockLabel;

for iStation = 1:nStations
   if Block.rotationInfo(Station.blockLabel(iStation)) == 1
      % Partials with *no* assumed block centroid                                                                       
      G(3*iStation-2:3*iStation, firstCol(iStation):lastCol(iStation)) = [R*Station.lon(iStation) R*Station.lat(iStation) -R 0 0 0 ;...
                                                                          0 0 0 R*Station.lon(iStation) R*Station.lat(iStation) -R ;...
                                                                          0 0 0 0 0 0];
   end
end

% Get rid of blocks that don't have enough stations on them
for i = 1:size(G, 2)/6;
   j                                        = 6*i-1;
   numSta(i)                                = numel(find(G(:, j)));
end
toDelete                                    = [6*find(numSta<2*minSta)-5 6*find(numSta<2*minSta)-4 6*find(numSta<2*minSta)-3 6*find(numSta<2*minSta)-2 6*find(numSta<2*minSta)-1 6*find(numSta<2*minSta)];
strainBlockIdx                              = setdiff(1:1:nBlocks*6, toDelete);
G(:,toDelete)                               = [];
