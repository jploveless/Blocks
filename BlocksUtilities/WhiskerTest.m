S = ReadStation('Obs.sta.data');

range = [229 251 30 53];
range = [128 147 30 46];
ip = inpolygon(S.lon, S.lat, range([1 2 2 1]), range([3 3 4 4]));

% Set map projection and gridding styles
mp                           = 'm_proj(''lambert'', ''long'', range(1:2) ,''lat'', range(3:4));';
mg                           = 'm_grid(''linestyle'', ''none'', ''tickdir'', ''out'', ''yaxislocation'', ''right'', ''xaxislocation'', ''bottom'', ''xlabeldir'', ''end'',''ticklen'', 0.01);';

% Set sf = 1 to save all figures and get the directory name for labeling
sf                           = 1;
dn                           = pwd;
dn                           = dn(end-9:end);

% Set slip rate limits for color coding
sSmaxRate                    = 10;
sSminRate                    = -40;
dSmaxRate                    = 10;
dSminRate                    = -10;


% Calculate the velocity magnitudes
dVel = mag([S.eastVel(:) S.northVel(:)], 2);
dVel(dVel>40) = 40;

% Make the figure, plotting vector components normalized by their magnitudes
figure; eval(mp); eval(mg); title('Observed velocities');
load WorldHiVectors; m_line(lon, lat, 'color', 0.5*[1 1 1], 'linewidth', 0.5);
vel = m_vec(10, S.lon(ip), S.lat(ip), S.eastVel(ip)./dVel(ip), S.northVel(ip)./dVel(ip), dVel(ip), 'shaftwidth', 1, 'headlength', 0.0, 'centered', 'yes');

'm_grid(''linestyle'', ''none'', ''tickdir'', ''out'', ''fontsize'', 0,''ticklen'', 0.0);';