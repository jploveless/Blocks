function demo_ge_windbarb2()

X = 4.778582;    % longitude
Y = 52.921329;   % latitude
Z = 100;         % elevation

U = 11;          % wind speed vector x-component
V = 4;           % wind speed vector y-component

% specify directory to store collada models:
daeDir = ['daes',filesep];   

% generate lime-colored collada models:
ge_barbdaes('daeDir',daeDir,...
            'barbColor','00FF00',...
            'barbAlpha','A0',...
            'msgToScreen',true)

% place the right arrow at the right location:
kmlStr = ge_windbarb(X,Y,Z,U,V,...
                     'rLink',daeDir,...
                'arrowScale',5e3);
    
%write the kmlStr to file:
ge_output('denhelder.kml',kmlStr,...
                   'name','De Kooy airfield')