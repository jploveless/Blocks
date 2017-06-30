function in = isbetweenaz(a1, a2, a3)
% isbetweenaz  Determines whether an azimuth is between two others.
%   IN = isbetweenaz(ANG1, ANG2, ANG3) determines whether the azimuth ANG3 lies
%   between the smaller angle between ANG1 and ANG2. Angles should be given in 
%   degrees. The results are returned to binary array IN. 
%

% Calculate angle between a3 and the other azimuths
d31 = a3 - a1;
d32 = a3 - a2;

d31(abs(d31) > 180) = d31(abs(d31) > 180) - sign(d31(abs(d31) > 180)).*360; 
d32(abs(d32) > 180) = d32(abs(d32) > 180) - sign(d32(abs(d32) > 180)).*360;

% If a3 is between a1 and a2, then the differences should be in opposite directions
in = ((abs(d31) + abs(d32)) <= 180) & sign(d31).*sign(d32) <= 0;

% Calculate angle between a1 and a2
d21 = a2 - a1;
