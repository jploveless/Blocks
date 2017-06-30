function G = GetSarLinearRampPartials(s);
% GETSARLINEARRAMPPARTIALS   Calculates the partial derivatives for a quadratic ramp across
%                   InSAR data.
%   G = GETSARRAMPPARTIALS(S) uses the S.LON, S.LAT positions of InSAR data to generate
%   the partial derivatives necessary for calculating the best-fitting quadratic ramp
%   across the data, using RAMP = G\DATA.
%

or = -s.lat-mean(-s.lat(:));
ab = -s.lon-mean(-s.lon(:));
G = [or(:) ab(:) ones(size(s.lon))];
