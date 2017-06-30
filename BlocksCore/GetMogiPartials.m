function pm = GetMogiPartials(Mogi, Station, pr)
% GETMOGIPARTIALS  Calculates partial derivatives for Mogi sources
%
% Uses Equation 7.14 of "Earthquake and Volcano Deformation" by P. Segall

% Convert Mogi depths to meters
Mogi.dep = 1e3*Mogi.dep;

% Check existence of specified Poisson's ratio
if ~exist('pr', 'var')
   pr = 0.25;
end

% Allocate space for partials matrix
dist = zeros(numel(Station.lon), numel(Mogi.lon));
az = dist;
pm = zeros(3*numel(Station.lon), numel(Mogi.lon));

% Loop through Mogi sources
for i = 1:size(Mogi.lon)
   % Calculate great circle distance and azimuth between source and stations
   dist(:, i) = gcdist(Mogi.lon(i), Mogi.lat(i), Station.lon, Station.lat); % Distance in meters
   az(:, i)   = sphereazimuth(Mogi.lon(i), Mogi.lat(i), Station.lon, Station.lat);
   
   % Calculate partials relating displacement (rate) to unit volume change (rate)
   % Segall Equation 7.14
   uz = (1 - pr)./pi.*Mogi.dep(i)./((dist(:, i).^2 + Mogi.dep(i).^2).^1.5);
   ur = (1 - pr)./pi.*dist(:, i)./((dist(:, i).^2 + Mogi.dep(i).^2).^1.5);
   
   % Convert radial displacement to east and north components
   ue = ur.*sind(az(:, i));
   un = ur.*cosd(az(:, i));
   
   % Insert components into partials matrix
   pm(1:3:end, i) = 1e9*ue;
   pm(2:3:end, i) = 1e9*un;
   pm(3:3:end, i) = 1e9*uz;
end

% Make some figures for testing

% Segall Figure 7.5
%figure
%plot(dist(:, 1)./Mogi.dep(i), ur./max(uz));
%hold on
%plot(dist(:, 1)./Mogi.dep(i), uz./max(uz));
%xlabel('Radial distance (r/depth)')
%ylabel('Normalized displacement')
%
%figure('position', [100 100 1000 200]);
%subplot(1, 4, 1)
%scatter(Station.lon, Station.lat, 25, uz, 'filled');
%title('Vertical displacement')
%subplot(1, 4, 2)
%scatter(Station.lon, Station.lat, 25, ur, 'filled');
%title('Radial displacement')
%subplot(1, 4, 3)
%scatter(Station.lon, Station.lat, 25, ue, 'filled');
%title('East displacement')
%subplot(1, 4, 4)
%scatter(Station.lon, Station.lat, 25, un, 'filled');
%title('North displacement')
