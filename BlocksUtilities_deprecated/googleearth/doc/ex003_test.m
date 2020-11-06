clear
close all
clc

Amp = 5e6;
a = linspace(-pi,pi,61)';
X = rad2deg(a);
Y = zeros(size(a));
Z = abs(sin(a*2)*Amp);

x=[];
y=[];
z=[];

for f=1:2:length(X)-1
    x=[x;X(f:f+1);NaN];
    y=[y;Y(f:f+1);NaN];
    z=[z;Z(f:f+1);NaN];
end

kmlStr = ge_plot3(X,Y,Z,'forceAsLine',true,'extrude',1);


p=mfilename('fullpath');
[ppath,pname,pext,pvrsn]=fileparts(p);
ge_output(['..',filesep,'kml',filesep,pname,'.kml'],kmlStr,'name',pname);