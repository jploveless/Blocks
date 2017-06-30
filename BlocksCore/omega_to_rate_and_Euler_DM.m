function [rrate, Elon, Elat] = omega_to_rate_and_Euler_DM(omegax, omegay, omegaz)
% omega_to_rate_and_Euler_DM.m

rrate = sqrt(omegax.^2 + omegay.^2 + omegaz.^2);
unit_x = omegax./rrate;
unit_y = omegay./rrate;
unit_z = omegaz./rrate;

% convert xyz coords to lon and lat
[Elon, Elat] = xyz_to_long_lat(unit_x, unit_y, unit_z);


% Convert longitude and latitude from radians to degrees
Elon                          = rad_to_deg(Elon);
Elat                          = rad_to_deg(Elat);

% Make sure we have west longitude
Elon(find(Elon < 0))          = Elon(find(Elon < 0)) + 360;
rrate                         = 1e6 * rad_to_deg(rrate);
