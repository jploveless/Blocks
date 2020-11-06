clear
close all
clc

load ..\data\res_tutorial\denhelder.mat
X = 4.778582;
Y = 52.921329;
Z = 100;


daeDir = '..\data\daes';
kmlStr = '';

for t=650:700%length(windDirX)-1
    
    str_s = datestr(serDate(t),'yyyy-mm-ddTHH:MM:SSZ');
    str_e = datestr(serDate(t+1),'yyyy-mm-ddTHH:MM:SSZ');
    
    kmlStr = [kmlStr,ge_windbarb(X,Y,Z,windDirX(t),windDirY(t),...
                                                      'daeDir',daeDir,...
                                                  'arrowScale',1e4,...
                                               'timeSpanStart',str_s,...
                                                'timeSpanStop',str_e)];
    
end

ge_kml('denhelder.kml',kmlStr)


ge_kmz('denhelder.kmz',...
        'resourceURLs',{daeDir,'denhelder.kml'},...
        'kmzTargetDir','..\kml')