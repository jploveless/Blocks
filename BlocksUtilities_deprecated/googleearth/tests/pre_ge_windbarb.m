clear
close all
clc

X = 4.778582;
Y = 52.921329;
Z = 100;

U = 11;
V = 4;

daeDir = 'daes';

ge_barbdaes('daeDir',daeDir,...
         'barbColor','00FF00',...
         'barbAlpha','FF',...
       'msgToScreen',true)

kmlStr = ge_windbarb(X,Y,Z,U,V,...
                      'daeDir',daeDir,...
                  'arrowScale',1e4);
    
FN = 'denhelder';
kmlFileName = [FN,'.kml'];
kmzFileName = [FN,'.kmz'];

ge_kml(kmlFileName,kmlStr,'name','De Kooy airfield')
ge_kmz(kmzFileName,...
        'resourceURLs',{daeDir,kmlFileName});
           
%now remove temporary kml file
if ispc
    eval(['!del ' kmlFileName]);
else
    eval(['!rm -f ' kmlFileName]); 
end
    