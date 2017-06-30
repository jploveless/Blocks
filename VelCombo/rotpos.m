function [xr, yr] = rotpos(X, Y, lon, lat, omegaEst);
% ROTPOS  Rotate time series positions into a new reference frame.
%   [XR, YR] = ROTPOS(X, Y, LON, LAT, OMEGA) rotates the position time 
%   series described by positions X, Y located at stations LON, LAT using
%   the rotation vector OMEGA.  X and Y are s-by-t arrays, containing the 
%   x and y positions at s stations made at times t.  LON and LAT are s-by-1
%   vectors.  OMEGA is as returned from ALIGNVELFIELDS.m.  The rotated position
%   time series are returned to XR and YR.
%

% Calculate partials
nStations                  = numel(lon);
G                          = zeros(3*nStations, numel(omegaEst));
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
% Eliminate verticals...
G(3:3:end, :)              = [];
% ...and z-shift
G(:, 6)                    = [];

% Calculate forward position corrections
dEst = G*omegaEst;
eCor = dEst(1:2:end);
nCor = dEst(2:2:end);

% Add corrections to position time series - static addition each time
xr = X + repmat(eCor, 1, size(X, 2));
yr = Y + repmat(nCor, 1, size(Y, 2));
