function demo_ge_gplot()


angleRad = linspace(0,(4/5)*2*pi,5)';
X = sin(angleRad);
Y = cos(angleRad);

% coordinate matrix:
V = [X,Y];

% connectivity matrix:
A = [0,0,1,1,0;...
     0,0,0,1,1;...
     1,0,0,0,1;...
     1,1,0,0,0;...
     0,1,1,0,0];

kmlStr = ge_gplot(A,V,'lineWidth',5.0,...
                      'lineColor','FF00FF00');

ge_output('demo_ge_gplot.kml',kmlStr);