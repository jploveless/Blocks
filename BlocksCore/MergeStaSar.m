function [Data, Sigma, Index] = MergeStaSar(Station, Sar)
% MergeStaSar  Merge GPS station and SAR velocities and uncertainties.

% Velocities and uncertainties
Data.eastVel    = Station.eastVel;
Sigma.eastVel   = Station.eastSig;
Data.northVel   = Station.northVel;
Sigma.northVel  = Station.northSig;
if isfield(Station, 'upVel')
   Data.upVel   = Station.upVel;
   Sigma.upVel  = Station.upSig;
end
Data.sar        = Sar.data;
Sigma.sar       = Sar.dataSig;

% Coordinates
Data.lon        = [Station.lon; Sar.lon];
Data.lat        = [Station.lat; Sar.lat];
Data.dep        = [Station.dep; Sar.dep];
Data.x          = [Station.x; Sar.x];
Data.y          = [Station.y; Sar.y];
Data.z          = [Station.z; Sar.z];
Data.blockLabel = [Station.blockLabel; Sar.blockLabel];

Data.nSta       = length(Station.lon);
Data.nSar       = length(Sar.lon);

% Rows containing SAR coordinates
Index.sarCoords = Data.nSta + 1:Data.nSar;