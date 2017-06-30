function futurestations(n)

% Define an ECSZ polygon
ecszpoly = [242 35.2; 243.2 34.1; 244.5 34.1; 244 35.6];

% Define a random station distribution...
xb = [min(ecszpoly(:, 1)) max(ecszpoly(:, 1))];
yb = [min(ecszpoly(:, 2)) max(ecszpoly(:, 2))];
dx = diff(xb);
dy = diff(yb);
xrand = xb(1) + rand(n, 1)*dx;
yrand = yb(1) + rand(n, 1)*dy;
% ...within the polygon
in = inpolygon(xrand, yrand, ecszpoly(:, 1), ecszpoly(:, 2));

% Write a new small station file
[S.lon, S.lat] = deal(xrand(in), yrand(in));
S.name = strcat(num2str([1:length(S.lon)]', '%04g'), repmat('_NEW', size(S.lon)));
zv = zeros(size(S.lon));
ov = ones(size(S.lon));
WriteStation(sprintf('futurestations_%g.sta.data', n), wrapTo360(S.lon), S.lat, zv, zv, ov, ov, zv, zv, ov, S.name)



