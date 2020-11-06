function dtrir = RakeTriPartials(dtri, strikes, saz)
%
% RakeTriPartials converts an existing matrix of triangular elastic dislocation partial 
% derivatives (expressed in terms of strike, dip, and tensile components, as produced
% by GetTriPartials) into a matrix containing the partials needed to solve for slip 
% magnitude with a fixed rake.
%
% Inputs:
%		dtri		= full matrix of triangular partials from GetTriPartials.m (3*nStations-by-3*nElements)
%		strikes	= nElements-by-1 vector containing the element strikes - contained in Partials.tristrikes
%		saz		= azimuth of the specified slip direction as projected onto the Earth's surface.  This 
%					  value will be converted into a rake value, which is unique to each element dependent
%					  on element strike.  Declare saz in degrees.
%
% Returns:
%		dtrir		= adjusted matrix of partial derivatives (3*nStations-by-nElements)
%

% determine whether or not strikes are given in radians; if so, convert to degrees
if max(abs(strikes)) < 2*pi;
	strikes				= rad2deg(strikes);
end

% determine actual fault rake from strike and surface azimuth
elrakes					= saz - rad2deg(strikes);

% calculate new matrix of partial derivatives
dtrir 					= [repmat(cosd(elrakes'), size(dtri, 1), 1).*dtri(:, 1:3:end) + repmat(sind(elrakes'), size(dtri, 1), 1).*dtri(:, 2:3:end)];