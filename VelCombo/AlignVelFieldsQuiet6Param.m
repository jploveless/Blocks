function [evEst, nvEst, G, omegaEst, wmean, nComSta] = AlignVelFieldsQuiet6Param(S1, S2, fuzz, omegaEstAP)
% AlignVelFieldsQuiet6Param   Aligns two velocity fields with 6-parameter transformation
%   [ev, nv] = AlignVelFieldsQuiet6Param(S1, S2) aligns the velocity fields given by the structures
%   S1 and S2, as read in by ReadStation.m. Stations collocated in both fields are aligned using
%   a 6-parameter transformation, and the velocity component adjustments needed to align S2 into
%   S1's reference frame are returned as ev, nv. S1 and S2 can alternatively be given as file names
%   to .sta.data files. 
%
%   [ev, nv] = AlignVelFieldsQuiet6Param(S1, S2, fuzz) specifies a tolerance parameter, in decimal
%   degrees, used for finding collocated stations. The default magnitude of 0.001 degrees. 
%

% If files were specified instead of structures...
if ischar(S1)
   S1                      = ReadStation(S1);
end
if ischar(S2)   
   S2                      = ReadStation(S2);
end

% Remove toggled off stations
S1                         = structsubset(S1, S1.tog);
S2                         = structsubset(S2, S2.tog);

% If tolerance was not specified
if ~exist('fuzz', 'var')
   fuzz = 0.001;
end

% Find colocated station (currently allows for latitude float)
%fprintf(1, '\nList of collocated stations:\n');
lon1                       = [];
lat1                       = [];
diffnv                     = [];
diffev                     = [];
esig                       = [];
nsig                       = [];
file1Idx                   = [];
file2Idx                   = [];

for i = 1:numel(S1.lon)
   for j = 1:numel(S2.lon)
      dlon                 = S1.lon(i)-S2.lon(j);
      dlat                 = S1.lat(i)-S2.lat(j);
      if (abs(dlon) < fuzz) && (abs(dlat) < fuzz)
         lon1              = [lon1 S1.lon(i)];
         lat1              = [lat1 S1.lat(i)];
         diffnv            = [diffnv (S1.northVel(i) - S2.northVel(j))];
         diffev            = [diffev (S1.eastVel(i) - S2.eastVel(j))];
         esig              = [esig sqrt(S1.eastSig(i).^2 + S2.eastSig(j).^2)];
         nsig              = [nsig sqrt(S1.northSig(i).^2 + S2.northSig(j).^2)];
         file1Idx          = [i file1Idx];
         file2Idx          = [j file2Idx];
         %fprintf(1, '%s %s\n', S1.name(i,:), S2.name(j,:));         
      end
   end
end
nComSta = numel(lon1);

% Solve for reference frame alignment
nStations                  = numel(lon1);
G                          = zeros(3*nStations, 6);
for i = 1:nStations
   rowIdx                  = (i-1)*3+1;
   colIdx                  = 1;
   [x y z]                 = sph2cart(deg2rad(lon1(i)), deg2rad(lat1(i)), 6371e6);
   R                       = GetCrossPartials([x y z]);
   [vn_wx ve_wx vu_wx]     = CartVecToSphVec(R(1,1), R(2,1), R(3,1), lon1(i), lat1(i));
   [vn_wy ve_wy vu_wy]     = CartVecToSphVec(R(1,2), R(2,2), R(3,2), lon1(i), lat1(i));
   [vn_wz ve_wz vu_wz]     = CartVecToSphVec(R(1,3), R(2,3), R(3,3), lon1(i), lat1(i));
   R                       = [ve_wx ve_wy ve_wz ; vn_wx vn_wy vn_wz ; vu_wx vu_wy vu_wz];
   G(rowIdx:rowIdx+2,colIdx:colIdx+5) = [R eye(3)];
end

% Delete vertical components, estimate rotation vector and calculate residuals
G(3:3:end, :)              = [];
G(:, 6)                    = [];
d                          = zeros(size(G,1), 1);
d(1:2:end)                 = diffev;
d(2:2:end)                 = diffnv;
d                          = d(:);
s                          = zeros(size(G,1), 1);
s(1:2:end)                 = esig;
s(2:2:end)                 = nsig;
W                          = diag(s);
%omegaEst                   = G\d;
cov                        = (G'*W*G)\eye(size(G, 2));
omegaEst                   = cov*G'*W*d;

if exist('omegaEstAP', 'var')
   omegaEst                = omegaEstAP;
end  

dEst                       = G*omegaEst;
nvEst                      = dEst(2:2:end);
evEst                      = dEst(1:2:end);
resid                      = d-dEst;
nvRes                      = resid(2:2:end);
evRes                      = resid(1:2:end);

% Report goodness of fit
velMag                     = sqrt(nvRes.^2+evRes.^2);
sigMag                     = sqrt((nsig).^2+(esig).^2);
velMag                     = velMag(:);
sigMag                     = sigMag(:);
wmean                      = mean(velMag./sigMag);

% Calculate partials new rotated velocites for velocity field 2
lon1                       = S2.lon;
lat1                       = S2.lat;
nStations                  = numel(lon1);
G                          = zeros(3*nStations, 6);
for i = 1:nStations
   rowIdx                  = (i-1)*3+1;
   colIdx                  = 1;
   [x y z]                 = sph2cart(deg2rad(lon1(i)), deg2rad(lat1(i)), 6371e6);
   R                       = GetCrossPartials([x y z]);
   [vn_wx ve_wx vu_wx]     = CartVecToSphVec(R(1,1), R(2,1), R(3,1), lon1(i), lat1(i));
   [vn_wy ve_wy vu_wy]     = CartVecToSphVec(R(1,2), R(2,2), R(3,2), lon1(i), lat1(i));
   [vn_wz ve_wz vu_wz]     = CartVecToSphVec(R(1,3), R(2,3), R(3,3), lon1(i), lat1(i));
   R                       = [ve_wx ve_wy ve_wz ; vn_wx vn_wy vn_wz ; vu_wx vu_wy vu_wz];
   G(rowIdx:rowIdx+2,colIdx:colIdx+5) = [R eye(3)];
end

G(3:3:end, :)              = [];
G(:, 6)                    = [];
dEst                       = G*omegaEst;
nvEst                      = dEst(2:2:end);
evEst                      = dEst(1:2:end);