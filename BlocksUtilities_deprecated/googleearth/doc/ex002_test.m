clear
close all
clc

xv=[18.46,-58.417309];
yv=[-33.9301,-34.611781];

kmlStr = ge_plot(xv,yv,'lineColor','FF0000FF');


p=mfilename('fullpath');
[ppath,pname,pext,pvrsn]=fileparts(p);
ge_output(['..',filesep,'kml',filesep,pname,'.kml'],kmlStr,'name',pname);