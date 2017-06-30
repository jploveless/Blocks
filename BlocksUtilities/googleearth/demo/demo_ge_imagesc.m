function demo_ge_imagesc()%% Demo ge_imagesc

load(fullfile(googleearthroot,'data','flujet.mat'))

data = X;

x = linspace(-20,15.0,size(data,2));
y = linspace(10,50,size(data,1));
cLimLow = 20%min(min(data));
cLimHigh = 50%max(max(data));
altitude = 10000;
alphaMatrix = ones(size(data))*0.75;

kmlFileName = 'demo_ge_imagesc.kml';

% add some NaNs at random places:
Ix = 1+round(rand(100,1)*(numel(data)-1));
data(Ix)=NaN;

% make the custom colormap
cmap = [0,0,1;0,1,0;1,0,0];
%cmap = 'winter';

figure
imagesc(x,y,data,[cLimLow,cLimHigh]);
colormap(cmap)
colorbar


output = ge_imagesc(x,y,data,...
                    'imgURL','flujet.png',...
                   'cLimLow',cLimLow,...
                  'cLimHigh',cLimHigh,...
                  'altitude',altitude,...
              'altitudeMode','absolute',...
                  'colorMap',cmap,...
               'alphaMatrix',alphaMatrix);

output2 = ge_colorbar(x(end),y(1),data,...
                          'numClasses',20,...
                             'cLimLow',cLimLow,...
                            'cLimHigh',cLimHigh,...
                       'cBarFormatStr','%+07.4f',...
                            'colorMap',cmap);

ge_output(kmlFileName,[output2 output],'name',kmlFileName);
                                           
                                           