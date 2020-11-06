function TestStrain
% Some simple tests of "uniform" strain on a sphere

R = 6371e6; % radius of the Earth (mm)
elonlon = 2e-7;
elonlat = -3e-7;
elatlat = 1e-7;

% The simple forward equations
N = 3;
lonVec = linspace(242, 243, N);
latVec = linspace(34, 35, N);
lon0 = mean(lonVec);
lat0 = mean(latVec);

lon0 = 242.80;
lat0 = 34.10;


[lonMat latMat] = meshgrid(lonVec, latVec);
latMat(latMat>=0) = 90 - latMat(latMat>=0);
latMat(latMat<0) = -90 - latMat(latMat<0);
lat0(lat0>=0) = 90 - lat0(lat0>=0);
lat0(lat0<0) = -90 - lat0(lat0<0);

% Classic forward model
vlon = elonlon * R * sind(lat0) .* deg2rad(lonMat - lon0) + elonlat * R * deg2rad(latMat - lat0);
vlat = elonlat * R * sind(lat0) .* deg2rad(lonMat - lon0) + elatlat * R * deg2rad(latMat - lat0);
latVec = latMat(:);
lonVec = lonMat(:);

% Try the three parameter version of the problem
m = zeros(3, 1);
m(1) = elonlon;
m(2) = elonlat;
m(3) = elatlat;
G3 = zeros(2*numel(latVec), 3);
for i = 1:numel(latVec)
   idx = 2*(i-1);
   G3(idx+1,:) = [R*deg2rad(lonVec(i)-lon0).*sind(lat0), R*deg2rad(latVec(i)-lat0), 0];
   G3(idx+2,:) = [0, R*deg2rad(lonVec(i)-lon0).*sind(lat0), R*deg2rad(latVec(i)-lat0)];
end

vest = G3*m;
veref = vest(1:2:end);
vnref = vest(2:2:end);
vestref = vest;
vest = vestref+0e0.*randn(size(vest));
ve = vest(1:2:end);
vn = vest(2:2:end);

% Invert for best fit using an assumed centroid
lon0cent = mean(lonVec);
lat0cent = mean(latVec);
G3 = zeros(2*numel(latVec), 3);
for k = 1:numel(latVec)
   idx = 2*(k-1);
   G3(idx+1,:) = [R*deg2rad(lonVec(k)-lon0cent).*sind(lat0cent), R*deg2rad(latVec(k)-lat0cent), 0];
   G3(idx+2,:) = [0, R*deg2rad(lonVec(k)-lon0cent).*sind(lat0cent), R*deg2rad(latVec(k)-lat0cent)];
end
mest = G3\vestref;
vcent = G3*mest;
vecent = vcent(1:2:end);
vncent = vcent(2:2:end);




% Set up an undirected grid search
polylon = [241.9 243.1 243.1 241.9 241.9];
polylat = [33.9 33.9 35.1 35.1 33.9];
K = 30;
lonRange = linspace(min(lonVec)-0.5, max(lonVec)+0.5, K);
latRange = linspace(min(latVec)-0.5, max(latVec)+0.5, K);
[lonGrid latGrid] = meshgrid(lonRange, latRange);
fitGrid = 999999.*ones(size(lonRange));
lonRange = lonGrid(:);
latRange = latGrid(:);
bestfit = 999999;

for i = 1:K
   for j = 1:K
      lon0 = lonGrid(i, j);
      lat0 = latGrid(i, j);
      G3 = zeros(2*numel(latVec), 3);
      for k = 1:numel(latVec)
         idx = 2*(k-1);
         G3(idx+1,:) = [R*deg2rad(lonVec(k)-lon0).*sind(lat0), R*deg2rad(latVec(k)-lat0), 0];
         G3(idx+2,:) = [0, R*deg2rad(lonVec(k)-lon0).*sind(lat0), R*deg2rad(latVec(k)-lat0)];
      end
      mest = G3\vestref;
      vguess = G3*mest;
      resid = sum(abs(vguess-vest));
      if ~inpolygon(lon0,90-lat0,polylon,polylat)
         resid = resid;
      end
      fitGrid(i,j) = resid;
   end
end
mi = find(fitGrid == min(fitGrid(:)));

lon0 = lonGrid(mi);
lat0 = latGrid(mi);
G3 = zeros(2*numel(latVec), 3);
for k = 1:numel(latVec)
   idx = 2*(k-1);
   G3(idx+1,:) = [R*deg2rad(lonVec(k)-lon0).*sind(lat0), R*deg2rad(latVec(k)-lat0), 0];
   G3(idx+2,:) = [0, R*deg2rad(lonVec(k)-lon0).*sind(lat0), R*deg2rad(latVec(k)-lat0)];
end
mest = G3\vestref;
vbest = G3*mest;
vebest = vbest(1:2:end);
vnbest = vbest(2:2:end);



% Plot the results
figure; hold on
fs = 18;
fitGrid = fitGrid./min(fitGrid(:));
surf(lonGrid, 90-latGrid, zeros(size(fitGrid)), (fitGrid)); shading interp;
colormap(gray);
brighten(0.75);

scale = 1e-2;
% latVec = 90-latVec;
axis equal;
plot(polylon, polylat, 'color', 0.0*[1 1 1])
arrow([lonVec(:) 90-latVec(:)], [lonVec(:)+scale*veref(:) 90-latVec(:)+scale*vnref(:)], 'Length', 20, 'Width', 5, 'BaseAngle', 60, 'EdgeColor', 'none', 'FaceColor', 'g');
arrow([lonVec(:) 90-latVec(:)], [lonVec(:)+scale*vecent(:) 90-latVec(:)+scale*vncent(:)], 'Length', 20, 'Width', 5, 'BaseAngle', 60, 'EdgeColor', 'r', 'FaceColor', 'none');
% arrow([lonVec(:) 90-latVec(:)], [lonVec(:)+scale*vebest(:) 90-latVec(:)+scale*vnbest(:)], 'Length', 20, 'Width', 5, 'BaseAngle', 60, 'EdgeColor', 'k', 'FaceColor', 'g');
load WorldHiVectors
plot(lon, lat, 'color', 0.0*[1 1 1])


% xlabel('Longitude', 'FontSize', fs);
% ylabel('Latitude', 'FontSize', fs);
title('\epsilon_{\phi\phi} = 0,  \epsilon_{\phi\theta} = 0,  \epsilon_{\theta\theta} = 10^{-7}', 'FontSize', fs);
ts = sprintf('\\epsilon_{\\phi\\phi} = %3.1f \\times 10^{-7},  \\epsilon_{\\phi\\theta} = %3.1f \\times 10^{-7},  \\epsilon_{\\theta\\theta} = %3.1f \\times 10^{-7}', elonlon*1e7, elonlat*1e7, elatlat*1e7);
title(ts, 'FontSize', fs);

set(gca, 'FontSize', fs);
axis equal;
set(gca, 'XLim', [min(lonGrid(:)) max(lonGrid(:))]);
set(gca, 'YLim', [min(90-latGrid(:)) max(90-latGrid(:))]);
ch = colorbar;
set(ch, 'FontSize', fs)
ticks_format('%4.1f', '%4.1f');
set(gcf, 'Render', 'painters');

% Try a genetic algorithm search
% [x fval] = ga(@fitnessfun, nvars, options);
global G;
G.lonVec = lonVec;
G.latVec = latVec;
G.vest   = vest;
G.R      = R;
G.vestref = vestref;
G.polylon = polylon;
G.polylat = polylat;



% [x,fval] = ga(@fitnessfun, 2)
[x,fval] = simulannealbnd(@fitnessfun, [242.5 90-34.5]);

% Check the velocities for the best fitting model
[vefit vnfit] = velfun(x);
arrow([lonVec(:) 90-latVec(:)], [lonVec(:)+scale*vefit(:) 90-latVec(:)+scale*vnfit(:)], 'Length', 20, 'Width', 5, 'BaseAngle', 60, 'EdgeColor', 'b', 'FaceColor', 'none');

plot(lon0, 90-lat0, 'gx', 'MarkerSize', 20, 'LineWidth', 2);
plot(x(1), 90-x(2), 'bo', 'MarkerSize', 20, 'LineWidth', 2);
plot(mean(lonVec), 90-mean(latVec), 'ro', 'MarkerSize', 20, 'LineWidth', 2);


function resid = fitnessfun(x)
global G

lon0 = x(1);
lat0 = x(2);
G3 = zeros(2*numel(G.latVec), 3);
for k = 1:numel(G.latVec)
   idx = 2*(k-1);
   G3(idx+1,:) = [G.R*deg2rad(G.lonVec(k)-lon0).*sind(lat0), G.R*deg2rad(G.latVec(k)-lat0), 0];
   G3(idx+2,:) = [0, G.R*deg2rad(G.lonVec(k)-lon0).*sind(lat0), G.R*deg2rad(G.latVec(k)-lat0)];
end
mest = G3\G.vestref;
vbest = G3*mest;
resid = sum(abs(vbest-G.vest));
if ~inpolygon(lon0,90-lat0, G.polylon, G.polylat)
   resid = resid + 1000;
end


function [vefit vnfit] = velfun(x)
global G

lon0 = x(1);
lat0 = x(2);
G3 = zeros(2*numel(G.latVec), 3);
for k = 1:numel(G.latVec)
   idx = 2*(k-1);
   G3(idx+1,:) = [G.R*deg2rad(G.lonVec(k)-lon0).*sind(lat0), G.R*deg2rad(G.latVec(k)-lat0), 0];
   G3(idx+2,:) = [0, G.R*deg2rad(G.lonVec(k)-lon0).*sind(lat0), G.R*deg2rad(G.latVec(k)-lat0)];
end
mest = G3\G.vestref;
vbest = G3*mest;
vefit = vbest(1:2:end);
vnfit = vbest(2:2:end);

