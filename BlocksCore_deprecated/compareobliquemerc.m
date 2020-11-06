function [mx, my, lx, ly] = compareobliquemerc(f, s)


% Matlab
[pole_lon, pole_lat]          = get_pole_from_gcps(deg2rad(f.lon1), deg2rad(f.lat1), deg2rad(f.lon2), deg2rad(f.lat2));
oblique_origin                = newpole(rad_to_deg(pole_lat), rad_to_deg(pole_lon));
mstruct                       = defaultm('mercator');
mstruct.origin                = oblique_origin;
mstruct                       = defaultm(mercator(mstruct));


[mx, my]                      = mfwdtran(mstruct, s.lat, s.lon);

% Mine
[lx, ly]                      = faultobliquemerc(s.lon, s.lat, f.lon1, f.lat1, f.lon2, f.lat2);
keyboard