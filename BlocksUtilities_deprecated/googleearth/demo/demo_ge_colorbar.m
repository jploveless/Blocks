function demo_ge_colorbar()

PosLong = [5 6 7 8];
PosLat = [53 52 51 50];
 
Z=100*randn(100000,1);

labels = {'wheat','grass','sugar beet','farmland'};
kmlStr = ge_colorbar(PosLong,PosLat,Z,...
                    'cBarBorderWidth',0,...
                         'numClasses',3,... % this is a tweak, there are actually 4 classes
                             'labels',labels,...
                               'name','click the icon to see the colorbar',...
                           'colorMap',rand(4,3),...
                  'showNumbersColumn',false);

                           
kmlFileName = 'demo_ge_colorbar.kml'; 

ge_output(kmlFileName,kmlStr,'name',kmlFileName)