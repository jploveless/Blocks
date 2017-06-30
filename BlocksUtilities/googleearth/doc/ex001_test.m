clear
close all
clc
%S = 'http://maps.google.com/mapfiles/kml/pal3/icon35.png';
S = '..\data\icons\circle_64x64_red.png';

t = 0:pi/50:10*pi;

kmlStr = ge_point(sin(t),cos(t),t*1e6,...
                          'iconColor','FFFFFFFF',...
                            'iconURL',S,...
                               'name','');

ge_kmz('ex001test.kmz',kmlStr,'name','ex001:ge_point',...
    'resourceURLs',{S},'targetDir',['..',filesep,'kml',filesep]);