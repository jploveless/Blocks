function [x, y, z] = EulerToOmega(lon, lat, rate);

[lon, lat, rate] = deal(deg2rad(lon), deg2rad(lat), deg2rad(rate)/1e6);

[x, y, z] = sph2cart(lon, lat, rate);