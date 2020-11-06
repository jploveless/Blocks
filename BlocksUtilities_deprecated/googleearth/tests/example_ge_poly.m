clear
close all
clc

angleRad = linspace(0,2*pi,6);

pentaX = [4*sin(angleRad);sin(angleRad+pi*0.2)];
pentaY = [4*cos(angleRad);cos(angleRad+pi*0.2)];

x = pentaX(:);
y = pentaY(:);

X = [];
Y = [];

for p=-25:6:25
    X=[X;NaN;x+p];
    Y=[Y;NaN;y+p];
end

kmlStr = ge_poly(X,Y,'polyColor','FF000000',...
                     'lineColor','FF00FF00',...
                     'lineWidth',2,...
                      'altitude',1e5,...
                       'extrude',1,...
                  'altitudeMode','relativeToGround');

ge_output('example_ge_poly.kml',kmlStr)