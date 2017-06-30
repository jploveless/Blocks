function G = GetSarCubicRampPartials(s);
% GETSARCUBICRAMPPARTIALS   Calculates the partial derivatives for a cubic ramp across
%                   InSAR data.
%   G = GETSARRAMPPARTIALS(S) uses the S.LON, S.LAT positions of InSAR data to generate
%   the partial derivatives necessary for calculating the best-fitting cubic ramp
%   across the data, using RAMP = G\DATA.
%

or = -s.lat-mean(-s.lat(:));
ab = -s.lon-mean(-s.lon(:));
G = [or(:) ab(:) or(:).*ab(:) or(:).^2.*ab(:) ab(:).^2.*or(:) or(:).^2 ab(:).^2 or(:).^3 ab(:).^3 ones(size(s.lon))];
