function [alon, alat] = getantipode(plon, plat)
% GETANTIPODE  Returns coordinates' antipode.
%   [ALON, ALAT] = GETANTIPODE(PLON, PLAT) returns the coordinates
%   ALON, ALAT of the antipode of the position with coordinates
%   PLON, PLAT.  Positions are input and output in degrees.
%

lat = -lat;
lon = 180 - mod(-lon, 360);
