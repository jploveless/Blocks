function [rake, saz, cstrike, xslip, yslip] = triaz(sslip, dslip, strike)
%
% TRIAZ   determines the surface azimuth of triangular slip vectors.
%    TRIAZGMT(LONC, LATC, SSLIP, DSLIP, STRIKE, FILE) uses the triangular
%    element strike and dip slip magnitudes (SSLIP, DSLIP), and the element
%    STRIKE (as given by GetTriPartials.m) to calculate the RAKE, surface 
%    azimuth SAZ, 0-360 strike CSTRIKE, and Cartesian slip vector components, 
%    (XSLIP, YSLIP).
%
%    [RAKE, SAZ, CSTRIKE, XSLIP, YSLIP] = TRIAZ(...) outputs the calculated
%    variables.
%
%    The resulting surface azimuths can be plotted by calling:
%    
%    >> QUIVER(LONC, LATC, XSLIP, YSLIP);
%
%    where (LONC, LATC) are the centroid coordinates of the elements.

% Check whether or not strikes were input in degrees or radians
if max(abs(strike(:))) > 2*pi % given in degrees
   strike = deg2rad(strike);
end

% Determine rakes
rake = atan2(dslip, sslip); % rake in radians, CW from left-lateral

% Calculate surface azimuth
saz = wrapTo360(rad2deg(strike + rake));
% Cleaned strikes
cstrike = wrapTo360(rad2deg(strike));
% Convert rakes back to degrees for output
rake = rad2deg(rake);

% Calculate the vector components in geographic coordinates
xslip = sqrt(sslip.^2 + dslip.^2).*sind(saz);
yslip = sqrt(sslip.^2 + dslip.^2).*cosd(saz);
