function G = GetSarQuadRampPartials(s);
% GetSarQuadRampPartials   Calculates the partial derivatives for a quadratic ramp across
%                   InSAR data.
%   G = GetSarQuadRampPartials(S) uses the S.LON, S.LAT positions of InSAR data to generate
%   the partial derivatives necessary for calculating the best-fitting quadratic ramp
%   across the data, using RAMP = G\DATA.
%

or = -s.lat-mean(-s.lat(:));
ab = -s.lon-mean(-s.lon(:));
G = [or(:) ab(:) or(:).*ab(:) or(:).^2 ab(:).^2 ones(size(s.lon))];
