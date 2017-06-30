% Comparing tri. strain to rect. strain

% Set up inputs

% Observation grid
[sta.lon, sta.lat] = meshgrid(100.01:.01:101, 24.8001:.01:25.4);
sta.z = -5*ones(size(sta.lon));
sta.lon = sta.lon(:); sta.lat = sta.lat(:); sta.z = sta.z(:);

[sta2.lon, sta2.lat] = meshgrid(100.01:.001:101, 24.8001:.001:25.4);
sta2.z = -5*(size(sta2.lon));
sta2.lon = sta2.lon(:); sta2.lat = sta2.lat(:); sta2.z = sta2.z(:);


% Segment
[seg.lon1, seg.lon2, seg.lat1, seg.lat2, seg.lDep, seg.dip, seg.bDep] = deal(100.25, 100.3, 25.2, 25, 15, 90, 0);

% Mesh
p = ReadPatches('/Users/jack/Desktop/testmesh.msh');
p = PatchCoords(p);

% Partials
Gseg = GetElasticPartials(seg, sta);
Gtri = GetTriPartials(p, sta);

Gsegs = GetElasticStrainPartials(seg, sta);
%[xx, yy, zz, xy, xz, yz] = okada_strain(0, 0, 0, 15, 90, 50, 15, 1, 0, 0, stac.lon(:), stac.lat(:), 0*stac.lon(:), 0.25);
Gtris = GetTriStrainPartials(p, sta);

% Slips
segslips = [1; 0; 0];
trislips = [1; 0; 0; 1; 0; 0];

% Deformations
segdef = Gseg*segslips;
tridef = Gtri*trislips;

% Strains
segstrain = Gsegs*segslips;
tristrain = Gtris*trislips;

i2seg = sqrt(segstrain(1:6:end).^2 + segstrain(2:6:end).^2 + 2*segstrain(4:6:end).^2);
i2tri = sqrt(tristrain(1:6:end).^2 + tristrain(2:6:end).^2 + 2*tristrain(4:6:end).^2);

% Plotting
[r, c] = deal(length(unique(sta.lon)), length(unique(sta.lat)));
[r2, c2] = deal(length(unique(sta2.lon)), length(unique(sta2.lat)));
%figure
%pcolor(unique(sta.lon), unique(sta.lat), reshape(segdef(1:3:end), c, r))
%title('Displacements, rect.')
%figure
%pcolor(unique(sta.lon), unique(sta.lat), reshape(tridef(1:3:end), c, r))
%title('Displacements, tri.')

figure
%pcolor(unique(sta.lon), unique(sta.lat), reshape(i2seg, c, r))
pcolor(unique(sta.lon), unique(sta.lat), reshape(segstrain(1:6:end), c, r)); caxis([-0.01 .01])
title('strain xx, rect.')
figure
%pcolor(unique(sta.lon), unique(sta.lat), reshape(i2tri, c, r))
pcolor(unique(sta.lon), unique(sta.lat), reshape(tristrain(1:6:end), c, r)); caxis([-0.01 .01])
title('strain xx, tri.')

figure
%pcolor(unique(sta2.lon), unique(sta2.lat), reshape(i2seg, c, r))
pcolor(unique(sta.lon), unique(sta.lat), reshape(i2seg, c, r)); caxis([-0.01 .01])
title('strain i2, rect.')
figure
%pcolor(unique(sta2.lon), unique(sta2.lat), reshape(i2tri, c, r))
pcolor(unique(sta.lon), unique(sta.lat), reshape(i2tri, c, r)); caxis([-0.01 .01])
title('strain i2, tri.')
%
%% Displacement based strain
%
%%[dxx, dxy] = gradient(reshape(segdef(1:3:end), c2, r2)); [dyx, dyy] = gradient(reshape(segdef(2:3:end), c2, r2));
%[dxx, dxy] = gradient(reshape(segdef(1:3:end), c, r)); [dyx, dyy] = gradient(reshape(segdef(2:3:end), c, r));
%i2segdef = sqrt(dxx.^2 + dyy.^2 + 2*(0.5*(dxy + dyx)).^2);
%figure
%%pcolor(unique(sta2.lon), unique(sta2.lat), i2segdef)
%pcolor(unique(sta.lon), unique(sta.lat), dxx); caxis([-0.01 .01])
%title('strain xx, rect. grad.')
%figure
%pcolor(unique(sta.lon), unique(sta.lat), i2segdef); caxis([-0.01 .01])
%title('strain i2, rect. grad.')
%
%[dxxt, dxyt] = gradient(reshape(tridef(1:3:end), c, r)); [dyxt, dyyt] = gradient(reshape(tridef(2:3:end), c, r));
%i2tridef = sqrt(dxxt.^2 + dyyt.^2 + 2*(0.5*(dxyt + dyxt)).^2);
%figure
%pcolor(unique(sta.lon), unique(sta.lat), i2tridef); caxis([-0.01 .01])
%title('strain i2, tri. grad.')
%%pcolor(unique(sta.lon), unique(sta.lat), dxxt); caxis([-0.01 .01])
