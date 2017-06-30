function in = inpolygonsphere(lon, lat, lonv, latv)
% inpolygonsphere   Tests where points are in a polygon on a sphere.
%   IN = inpolygonsphere(LON, LAT, LONV, LATV) tests whether the points
%   specified by LON and LAT lie within the polygon on the surface of a 
%   sphere defined by ordered vertices LONV and LATV. The result is 
%   returned to the logical index IN.
%

% Array sizes
np = numel(lon); % Number of interior points to test
nv = numel(lonv); % Number of polygon vertices

% Determine a test point, by projecting a vertex a small distance along 
% the mean azimuth of the sides originating from it.
[~, n] = max(latv);
n1 = n - 1; n1(n1 == 0) = nv;
n2 = n + 1; n2(n2 > nv) = 1;
saz = sphereazimuth(lonv(n), latv(n), lonv([n1 n2]), latv([n1 n2]));
saz = mean(mod(saz, 360));
[tlon, tlat] = gcpoint(lonv(n), latv(n), saz, 1e-3);

% Calculate azimuths between test point and vertices, and between test point and interior points
taz = sphereazimuth(tlon, tlat, [lonv; lon], [latv; lat]);

% Test 1: azimuth to interior point should lie between azimuth to bounding vertices
% Test by subtracting test-I.P. azimuth from vertex azimuth; pass if different signs
% test1 = isbetweenaz(repmat(taz(1:nv), 1, np), repmat(taz([2:nv, 1]), 1, np), repmat(taz(nv+1:end)', nv, 1));
test1 = NaN(nv, np);
parfor i = 1:np
   test1(:, i) = isbetweenaz(taz(1:nv), taz([2:nv, 1]), taz(nv+i));
end

% Calculate circulated edge azimuths
eaz = sphereazimuth(lonv, latv, lonv([2:end, 1]), latv([2:end, 1]));

% Calculate azimuths between vertices and test point, and between vertices and interior points
Tlon = [tlon lon'];
Tlat = [tlat lat'];
vaz = NaN(nv, np+1);
parfor i = 1:np+1
   vaz(:, i) = sphereazimuth(lonv, latv, Tlon(i), Tlat(i));
end
% vaz = sphereazimuth(repmat(lonv, 1, np+1), repmat(latv, 1, np+1), repmat(Tlon, nv, 1), repmat(Tlat, nv, 1));

% Test 2: azimuth to test point should be on the same side of the segment (E-W) as that to interior point
% Test by comparing the difference between the azimuth to test point and segment azimuth with the 
% difference between the azimuth to interior points and segment azimuth

ewvaz1 = repmat(vaz(:, 1), 1, np) - repmat(eaz, 1, np); 
ewvaz2 = vaz(:, 2:end) - repmat(eaz, 1, np); 
test2 = sign(mod(ewvaz1, 360) - 180).*sign(mod(ewvaz2, 360) - 180) <= 0; % Signs denote east or west

% Find segments passing both tests
test = test1.*test2;

% Sum down the rows; even numbers mean interior points
in = rem(sum(test), 2) == 0 & sum(test1) > 0;