function demo_ge_makekmz()

% specify directory to store collada models:
rLinkStr = ['barbs',filesep];

% generate lime-colored collada models:
ge_barbdaes('daeDir',rLinkStr,...
            'barbColor','FFFF00',...
            'barbAlpha','A0',...
            'msgToScreen',false)

kmlStr = ge_windbarb(10,20,300,10,0,...
    'arrowScale',1e5,...
    'rLink',rLinkStr);

ge_output('barbs.kml',kmlStr)

sources = {fullfile(googleearthroot,'data','barbdaes');
            'barbs.kml'};

destinations = {rLinkStr;
                   'barbs.kml'};

ge_makekmz('barbs.kmz','sources',sources,...
                  'destinations',destinations)

















