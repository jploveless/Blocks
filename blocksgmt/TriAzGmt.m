function [rake, saz, strike, refleng] = TriAzGmt(lonc, latc, sslip, dslip, strike, outfile, refmag)
%
% TriAzGmt writes a file for use with GMT's vector plotting
% command:
% >> psxy -SV
%
% TriAzGmt(lonc, latc, sslip, dslip, strike, file) uses the triangular
% element centroid coordinates (lonc, latc), the element strike and 
% dip slip magnitudes (sslip, dslip), and the element strike (as given
% by GetTriPartials.m) to write a file appropriate for plotting with GMT.
%

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

% Calculate the magnitude-weighted length of the vectors
smag = mag([sslip(:), dslip(:)], 2);
leng = 0.5*smag./max(smag);
leng(leng < 0.03) = -1;
keyboard
if exist('refmag', 'var')
   refleng = 0.5*refmag/max(smag);
end

% Write the file
fid = fopen(outfile, 'w');
fprintf(fid, '%g %g %g %g %g\n', [lonc(:)'; latc(:)'; smag(:)'; saz(:)'; leng(:)']);
fclose(fid);